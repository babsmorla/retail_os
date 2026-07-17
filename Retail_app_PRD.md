# RetailOs — Product Requirements Document

**Stack:** Ruby on Rails (API + Hotwire/Turbo or React frontend), PostgreSQL, Sidekiq/Redis, Pundit, Devise
**Version:** Draft v1.0

---

## 1. Overview

RetailOs is a retail management system for issuing sales, printing receipts, tracking inventory, and maintaining accounting records for a general retail store (or small chain of stores). It supports role-based access so that store owners, cashiers, and inventory staff each work within clearly bounded permissions, while all financial and stock movements remain fully auditable.

**Primary users:**
- **Admin** — store owner / manager, full system control.
- **Shop Keeper** — cashier, issues sales and receipts.
- **Inventory Officer** *(renamed from "Product Restocking")* — manages stock replenishment, subject to admin approval.

---

## 2. Goals

- Give the business a single source of truth for sales, inventory, and accounting.
- Prevent tampering with confirmed sales (immutability = trustworthy audit trail).
- Keep inventory in sync automatically: every confirmed sale deducts stock; every approved restock adds it.
- Support reporting (daily/weekly/monthly) for decision-making.
- Keep the system simple enough for non-technical cashiers to use quickly at checkout.

---

## 3. Recommended Tech Stack

| Concern | Recommendation |
|---|---|
| Framework | Ruby on Rails 7.x (Hotwire/Turbo + Stimulus for a fast, low-JS UI; or Rails API + React if you want a separate POS frontend/tablet app) |
| Database | PostgreSQL |
| Authentication | Devise |
| Authorization | Pundit (policy-per-model maps cleanly to your 3 roles + permission matrix below) |
| Background jobs | Sidekiq + Redis (receipt generation, report generation, email/SMS notifications) |
| PDF receipts | Prawn or WickedPDF |
| Barcode/SKU scanning (optional, future) | `rqrcode`/`barby` for generating barcodes; JS barcode scanner lib on frontend |
| Audit trail | `paper_trail` gem — tracks every change to Sale, Product, Return, Restock records |
| Money handling | `money-rails` gem (avoid float rounding errors on currency) |
| Testing | RSpec + FactoryBot + Capybara |
| Deployment | Docker + a Postgres-backed host (Render/Fly.io/Heroku/VPS) |

---

## 4. Roles & Permission Matrix

| Capability | Admin | Shop Keeper | Inventory Officer |
|---|:---:|:---:|:---:|
| Issue sale / print receipt | ✅ | ✅ | ❌ |
| Search sale by receipt ID | ✅ | ✅ (own sales only, optional) | ❌ |
| Edit sale after confirmation | ❌ (no one can) | ❌ | ❌ |
| Delete/void a sale | ✅ (with reason, logged) | ❌ | ❌ |
| Confirm/approve a return | ✅ | ❌ (can *initiate* a return request) | ❌ |
| Add / update inventory directly | ✅ | ❌ | ❌ |
| Submit restock request | ✅ | ❌ | ✅ |
| Approve restock request (adds to live inventory) | ✅ | ❌ | ❌ |
| Edit a restock request after approval | ❌ | ❌ | ❌ |
| Add / remove Shop Keeper accounts | ✅ | ❌ | ❌ |
| Assign/change staff roles | ✅ | ❌ | ❌ |
| Reset own password | ✅ | ✅ | ✅ |
| Reset another user's password | ✅ | ❌ | ❌ |
| View sales reports (day/week/month/custom) | ✅ | ❌ (optionally: own shift only) | ❌ |
| View accounting/financial records | ✅ | ❌ | ❌ |
| Manage categories | ✅ | ❌ (view only) | ❌ (view only) |

> **Rule of thumb enforced throughout:** once a sale is *confirmed*, it becomes immutable. Corrections happen via a separate **Return** or **Void** workflow, never by editing the original record — this is what keeps the accounting trustworthy.

---

## 5. Core Domain Models

```
User
 ├─ id
 ├─ full_name
 ├─ email
 ├─ phone
 ├─ role            (enum: admin, shop_keeper, inventory_officer)
 ├─ store_id         (FK, nullable if single-store)
 ├─ active           (boolean — admin can deactivate instead of hard-delete)
 └─ timestamps

Store (optional now, future-proofs multi-branch)
 ├─ id
 ├─ name
 ├─ location
 └─ timestamps

Category
 ├─ id
 ├─ name
 ├─ store_id (nullable)
 └─ timestamps

Product
 ├─ id
 ├─ name
 ├─ sku / barcode
 ├─ category_id      (nullable — categories optional per your spec)
 ├─ unit_price        (money)
 ├─ cost_price         (money, for margin/profit reporting)
 ├─ quantity_on_hand
 ├─ reorder_level      (optional: trigger low-stock alerts)
 ├─ store_id
 └─ timestamps

Sale
 ├─ id
 ├─ receipt_number    (unique, human-searchable, e.g. RS-2026-000123)
 ├─ shop_keeper_id    (FK -> User)
 ├─ store_id
 ├─ status            (enum: pending, confirmed, voided)
 ├─ subtotal
 ├─ discount_total
 ├─ tax_total
 ├─ grand_total
 ├─ payment_method     (cash, card, mobile_money, etc.)
 ├─ confirmed_at
 ├─ voided_at
 ├─ voided_by_id       (FK -> User, admin only)
 ├─ void_reason
 └─ timestamps

SaleItem
 ├─ id
 ├─ sale_id
 ├─ product_id
 ├─ quantity
 ├─ unit_price_at_sale  (snapshot — never trust live product price for historic sales)
 ├─ line_total
 └─ timestamps

Receipt
 ├─ id
 ├─ sale_id (1:1) 
 ├─ pdf_file (ActiveStorage attachment)
 ├─ printed_at
 ├─ reprint_count
 └─ timestamps

Return
 ├─ id
 ├─ sale_id
 ├─ sale_item_id
 ├─ quantity_returned
 ├─ reason
 ├─ status            (enum: pending, approved, rejected)
 ├─ requested_by_id    (FK -> User, shop keeper)
 ├─ approved_by_id     (FK -> User, admin)
 └─ timestamps

RestockRequest
 ├─ id
 ├─ product_id
 ├─ requested_by_id    (FK -> User, inventory officer)
 ├─ quantity_requested
 ├─ status            (enum: pending, approved, rejected)
 ├─ approved_by_id     (FK -> User, admin)
 ├─ approved_at
 └─ timestamps

AccountingEntry (ledger — simplest version)
 ├─ id
 ├─ entry_type        (enum: sale_revenue, refund, restock_cost, adjustment)
 ├─ reference_type / reference_id  (polymorphic -> Sale, Return, RestockRequest)
 ├─ amount
 ├─ store_id
 ├─ recorded_at
 └─ timestamps

AuditLog (or rely on paper_trail's built-in `versions` table)
 ├─ id
 ├─ user_id
 ├─ action
 ├─ auditable_type / auditable_id
 ├─ changes (jsonb)
 └─ created_at
```

---

## 6. Feature Breakdown by Role

### Admin
- Full CRUD on products, categories, stores.
- Create, deactivate, or delete Shop Keeper / Inventory Officer accounts.
- Assign or change a staff member's role.
- Directly add or adjust inventory (bypasses the restock-approval flow — useful for corrections).
- Approve or reject restock requests submitted by Inventory Officers.
- Approve or reject return requests submitted by Shop Keepers.
- Void a confirmed sale, with a mandatory reason (logged, reverses stock and accounting entries).
- View sales and accounting reports: daily, weekly, monthly, custom date range; filterable by store, shop keeper, category.
- Search any sale by receipt ID, date, shop keeper, or customer reference.
- Reset any user's password.

### Shop Keeper
- Issue a new sale: add products (by search or category browse), adjust quantities, apply discounts (if permitted), select payment method.
- **Confirm sale** — a deliberate second step before the sale is locked in (prevents accidental checkouts). Confirming a sale:
  - Deducts sold quantities from `quantity_on_hand`.
  - Generates the receipt (PDF + printable/print-to-thermal-printer).
  - Creates the accounting entry.
  - Locks the record — no further edits possible.
- Search for a past sale by receipt ID (own sales, or all if admin allows).
- Reprint a receipt (tracked via `reprint_count`).
- Initiate a return request (cannot approve it — goes to Admin).
- Reset own password only.

### Inventory Officer
- View current inventory levels and low-stock items.
- Submit a restock request (product + quantity + optional note/supplier reference).
- View status of their own restock requests (pending/approved/rejected).
- **Cannot** edit a request once submitted for approval, and **cannot** edit it after approval — if quantities were wrong, they submit a new request or ask Admin to adjust directly.
- **Cannot** add users, view accounting, or issue sales.

---

## 7. Key Workflows

### 7.1 Issue Sale & Receipt
```
Shop Keeper opens "New Sale"
 → searches/browses products (by name, SKU, or category)
 → adds items + quantities to cart
 → system validates quantity_on_hand ≥ requested quantity
 → applies discount/tax if applicable
 → Shop Keeper reviews cart totals
 → Shop Keeper clicks "Confirm Sale"
     → Sale.status: pending → confirmed
     → SaleItems locked with unit_price_at_sale snapshot
     → Product.quantity_on_hand decremented per item
     → Receipt generated (PDF) + receipt_number assigned
     → AccountingEntry (sale_revenue) created
 → Receipt printed / sent to printer queue
```

### 7.2 Restock Approval
```
Inventory Officer submits RestockRequest (status: pending)
 → Admin reviews request
 → Admin approves:
     → Product.quantity_on_hand incremented
     → AccountingEntry (restock_cost) created if cost tracked
     → RestockRequest.status: approved (locked, immutable)
 → Admin rejects:
     → RestockRequest.status: rejected, with reason
     → No inventory change
```

### 7.3 Return / Refund
```
Shop Keeper initiates Return against a confirmed Sale/SaleItem
 → Return.status: pending
 → Admin reviews
 → Admin approves:
     → Product.quantity_on_hand incremented (item back in stock)
     → AccountingEntry (refund) created
     → Return.status: approved
 → Admin rejects:
     → Return.status: rejected, no changes
```

### 7.4 Void Sale (Admin only)
```
Admin selects a confirmed sale → provides void_reason
 → Sale.status: confirmed → voided
 → Stock quantities restored
 → Offsetting AccountingEntry created (so the ledger stays balanced, nothing is silently deleted)
 → Original sale record retained for audit — never hard-deleted
```

### 7.5 Reporting
```
Admin selects a date range + optional filters (store, shop keeper, category)
 → System aggregates confirmed Sales + Returns + Voids into:
     - Total revenue
     - Total items sold
     - Top-selling products/categories
     - Returns/void rate
     - Per-shop-keeper performance (optional)
 → Exportable as PDF/CSV
```

---

## 8. Business Rules (Guardrails)

1. A sale is only "real" once **confirmed** — pending sales don't touch inventory or accounting.
2. Confirmed sales are **immutable**. Mistakes are corrected via Return or Void, both admin-gated.
3. Restock requests only touch live inventory **after admin approval** — never on submission.
4. Approved restocks and confirmed sales cannot be edited by anyone, including Admin, through direct field edits — only through a new offsetting transaction, to preserve the audit trail.
5. Only Admin manages user accounts and roles.
6. Only Admin and the sale's own Shop Keeper (optional, configurable) can search that sale by receipt ID; Admin can search all.
7. Categories are optional on a Product — products can exist uncategorized.
8. `unit_price_at_sale` is always snapshotted on the SaleItem — a later price change must never alter historical receipts or reports.

---

## 9. Non-Functional Requirements

- **Auditability:** every state-changing action (sale confirm, void, restock approve/reject, return approve/reject, role change) is logged with actor, timestamp, and before/after state (`paper_trail`).
- **Performance:** product search should return results in <200ms for catalogs up to ~50k SKUs (indexed on `name`, `sku`, `category_id`).
- **Printing:** support both a browser-print-to-PDF flow and, later, direct thermal receipt printer integration (ESC/POS over USB/Bluetooth) — architect the receipt generator so the print target is swappable.
- **Offline resilience (future):** consider a queued-sale mechanism if store internet is unreliable — not in scope for v1 but worth designing the Sale model to accommodate a `synced_at` field later.
- **Security:** role checks enforced at the Pundit policy layer, not just hidden in the UI. Passwords via Devise (bcrypt). Consider 2FA for Admin accounts.
- **Data integrity:** all monetary fields use `money-rails` (integer cents under the hood) — never raw floats.

---

## 10. Suggested Rails App Structure

```
app/
 ├─ models/
 │   ├─ user.rb, store.rb, category.rb, product.rb
 │   ├─ sale.rb, sale_item.rb, receipt.rb
 │   ├─ return.rb, restock_request.rb
 │   └─ accounting_entry.rb
 ├─ policies/                # Pundit — one per model
 │   ├─ sale_policy.rb
 │   ├─ product_policy.rb
 │   ├─ restock_request_policy.rb
 │   └─ user_policy.rb
 ├─ services/                 # business logic, keep controllers thin
 │   ├─ sales/confirm_sale_service.rbGoogle 2
 │   ├─ sales/void_sale_service.rb
 │   ├─ restocking/approve_restock_service.rb
 │   ├─ returns/approve_return_service.rb
 │   └─ reports/sales_report_service.rb
 ├─ controllers/
 │   ├─ admin/...             # admin-only namespace
 │   ├─ sales_controller.rb
 │   ├─ restock_requests_controller.rb
 │   └─ reports_controller.rb
 ├─ jobs/
 │   ├─ generate_receipt_pdf_job.rb
 │   └─ generate_report_job.rb
 └─ views/ (or a separate React/Turbo frontend)
```

Using a `services/` layer for the "confirm sale," "approve restock," and "void sale" actions keeps the state-transition + inventory + accounting side effects in one testable place, rather than scattered across controllers/callbacks.

---

## 11. Suggested Next Steps

1. Confirm single-store vs. multi-store scope for v1 (affects `Store` model necessity now vs. later).
2. Decide receipt output: PDF only, or direct thermal printer support from day one.
3. Decide whether Shop Keepers see only their own sales or all sales (search scope).
4. Set up Rails app skeleton with Devise + Pundit + the models above.
5. Build the Sale confirm/void service objects first — they're the core of the system's integrity.
6. Layer in reporting once the core sale/inventory loop is solid.

---

## 12. Future Enhancements (Not v1)

- Multi-store support with per-store inventory and consolidated admin reporting.
- Barcode scanning at checkout.
- SMS/email receipts to customers.
- Supplier management tied to restock requests.
- Offline-first sale queueing for unstable connections.
- Customer loyalty/points tracking.
