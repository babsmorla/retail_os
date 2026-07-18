# Wipes all operational data for a store (sales, products, categories,
# employees) while preserving the admin's own account and the Store
# record itself. Intended for admins testing the system who want to
# start fresh before going live with real data.
class ShopResetService
  def initialize(store:, admin:)
    @store = store
    @admin = admin
  end

  def call
    ActiveRecord::Base.transaction do
      sale_ids = Sale.where(store: @store).pluck(:id)

      # Children of Sale first, to avoid orphaned/blocked deletes.
      SaleItem.where(sale_id: sale_ids).delete_all
      Receipt.where(sale_id: sale_ids).delete_all
      Sale.where(id: sale_ids).delete_all

      AccountingEntry.where(store: @store).delete_all

      product_ids = Product.where(store: @store).pluck(:id)
      StockAdjustment.where(product_id: product_ids).delete_all
      StockMovement.where(store: @store).delete_all

      Product.where(store: @store).delete_all
      Category.where(store: @store).delete_all

      # Destroy employees owned by this admin. This cascades their
      # memberships automatically (User has_many :memberships, dependent: :destroy).
      # Their sales were already cleared above, so User's
      # `has_many :sales, dependent: :restrict_with_error` guard won't block this.
      @admin.employees.destroy_all
    end

    true
  end
end
