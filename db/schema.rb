# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_16_091301) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounting_entries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "entry_type", default: 0, null: false
    t.bigint "reference_id", null: false
    t.string "reference_type", null: false
    t.bigint "store_id"
    t.datetime "updated_at", null: false
    t.index ["reference_type", "reference_id"], name: "index_accounting_entries_on_reference"
    t.index ["store_id"], name: "index_accounting_entries_on_store_id"
  end

  create_table "categories", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.integer "category_type"
    t.string "color"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon"
    t.string "name"
    t.bigint "store_id"
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_categories_on_store_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["store_id"], name: "index_memberships_on_store_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.bigint "category_id"
    t.decimal "cost_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.integer "low_stock_threshold"
    t.string "name", null: false
    t.integer "quantity_on_hand", default: 0, null: false
    t.integer "reorder_level", default: 5
    t.string "sku"
    t.bigint "store_id"
    t.decimal "unit_price", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["sku", "store_id"], name: "index_products_on_sku_and_store_id", unique: true
    t.index ["store_id"], name: "index_products_on_store_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "printed_at"
    t.integer "reprint_count", default: 0, null: false
    t.bigint "sale_id", null: false
    t.bigint "store_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sale_id"], name: "index_receipts_on_sale_id"
    t.index ["store_id"], name: "index_receipts_on_store_id"
  end

  create_table "sale_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "line_total", precision: 10, scale: 2
    t.bigint "product_id", null: false
    t.integer "quantity", null: false
    t.bigint "sale_id", null: false
    t.decimal "unit_price_at_sale", precision: 10, scale: 2
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sale_items_on_product_id"
    t.index ["sale_id"], name: "index_sale_items_on_sale_id"
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.decimal "discount_total", precision: 10, scale: 2, default: "0.0"
    t.decimal "grand_total", precision: 10, scale: 2, default: "0.0"
    t.integer "payment_method", default: 0
    t.string "receipt_number", null: false
    t.bigint "shop_keeper_id", null: false
    t.integer "status", default: 0, null: false
    t.bigint "store_id"
    t.decimal "subtotal", precision: 10, scale: 2, default: "0.0"
    t.decimal "tax_total", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.index ["receipt_number"], name: "index_sales_on_receipt_number", unique: true
    t.index ["shop_keeper_id"], name: "index_sales_on_shop_keeper_id"
    t.index ["store_id"], name: "index_sales_on_store_id"
  end

  create_table "stock_adjustments", force: :cascade do |t|
    t.integer "adjustment_type"
    t.datetime "created_at", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.string "reason"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["product_id"], name: "index_stock_adjustments_on_product_id"
    t.index ["user_id"], name: "index_stock_adjustments_on_user_id"
  end

  create_table "stock_movements", force: :cascade do |t|
    t.integer "balance_after"
    t.datetime "created_at", null: false
    t.integer "movement_type"
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.integer "reference_id"
    t.string "reference_type"
    t.bigint "store_id"
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_stock_movements_on_product_id"
    t.index ["store_id"], name: "index_stock_movements_on_store_id"
  end

  create_table "stores", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name"
    t.bigint "owner_id"
    t.string "phone_number"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.integer "store_id"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["owner_id"], name: "index_users_on_owner_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "accounting_entries", "stores"
  add_foreign_key "memberships", "stores"
  add_foreign_key "memberships", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "receipts", "sales"
  add_foreign_key "receipts", "stores"
  add_foreign_key "sale_items", "products"
  add_foreign_key "sale_items", "sales"
  add_foreign_key "sales", "users", column: "shop_keeper_id"
  add_foreign_key "stock_adjustments", "products"
  add_foreign_key "stock_adjustments", "users"
  add_foreign_key "stock_movements", "products"
  add_foreign_key "users", "users", column: "owner_id"
end
