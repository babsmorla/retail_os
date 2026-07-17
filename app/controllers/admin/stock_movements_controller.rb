class Admin::StockMovementsController < ShopKeeper::BaseController
  before_action :set_product

  def index
    # Only allow access to movements of active products, 
    # or handle the deactivated product gracefully.
    @stock_movements = @product.stock_movements
                               .includes(:reference)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(5)
  end

  private

  def set_product
    # Ensure the product exists. 
    # If you want to restrict viewing movements for deactivated products, 
    # you could use Product.active.find(params[:product_id])
    @product = Product.find(params[:product_id])
  end
end