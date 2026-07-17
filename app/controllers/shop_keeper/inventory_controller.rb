module ShopKeeper
  class InventoryController < BaseController
    skip_before_action :ensure_shop_keeper!

    # Enforce admin check
    before_action :authenticate_admin!
    def index
      # 1. Scope everything to the current_store
      base_scope = current_store.products.active

      @products = base_scope.includes(:category, :stock_movements)
                            .page(params[:page])
                            .per(5)

      # 2. Search & Filters (scoped to base_scope)
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

      case params[:status]
      when "low"       then @products = @products.where("quantity_on_hand <= reorder_level AND quantity_on_hand > 0")
      when "out"       then @products = @products.where(quantity_on_hand: 0)
      when "available" then @products = @products.where("quantity_on_hand > reorder_level")
      end

      # 3. Scoped categories for the filter sidebar
      @categories = current_store.categories

      # 4. DASHBOARD NUMBERS (Restricted to current store)
      @total_products = base_scope.count
      @total_stock    = base_scope.sum(:quantity_on_hand)
      @in_stock       = base_scope.where("quantity_on_hand > reorder_level").count
      @low_stock      = base_scope.where("quantity_on_hand <= reorder_level AND quantity_on_hand > 0").count
      @out_of_stock   = base_scope.where(quantity_on_hand: 0).count

      # 5. Recent movements (Join through the store's products)
      @recent_movements = current_store.stock_movements
                                       .joins(:product)
                                       .order(created_at: :desc)
                                       .limit(10)
    end
  end
end
