# app/controllers/receipts_controller.rb
class ReceiptsController < ShopKeeper::BaseController
  # Remove before_action :authenticate_user! if it's already in BaseController

  def show
    # Your existing logic...
    if current_user.admin?
      @receipt = Receipt.find(params[:id])
    else
      # Now you can safely use current_store to scope the search
      @receipt = current_store.receipts
                              .joins(:sale)
                              .find_by!(id: params[:id], sales: { shop_keeper_id: current_user.id })
    end

    @sale = @receipt.sale
    render layout: "ticket"
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "You are not authorized to view this receipt."
  end
end
