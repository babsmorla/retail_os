class Admin::InventoryAdjustmentsController < ShopKeeper::BaseController
def new
    @products = Product.order(:name).page(params[:page]).per(5)
    @adjustment = StockAdjustment.new
  end



  def create
  product = Product.find(adjustment_params[:product_id])

  Inventory::AdjustStockService.new(
    product: product,
    quantity: adjustment_params[:quantity],
    adjustment_type: adjustment_params[:adjustment_type],
    reason: adjustment_params[:reason],
    user: current_user
  ).call

  redirect_to shop_keeper_inventory_index_path,
              notice: "Stock adjusted successfully"
end



  private


  def adjustment_params

    params.require(:stock_adjustment)
    .permit(
      :product_id,
      :quantity,
      :adjustment_type,
      :reason
    )

  end

end


