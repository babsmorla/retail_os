module ShopKeeper
  class ReceiptsController < BaseController
    def show
  # Define the base eager loading to avoid N+1 queries
  includes_list = { sale: [:sale_items, :shop_keeper, { sale_items: :product }] }

  if current_user.admin?
    # Admins can see any receipt
    @receipt = Receipt.includes(includes_list).find(params[:id])
  else
    # Non-admins can see any receipt belonging to their current store
    # We use current_store to scope the search, ensuring they can't access other stores' data
    @receipt = current_store.receipts
                            .includes(includes_list)
                            .find_by!(id: params[:id])
  end

  @sale = @receipt.sale
  render layout: "ticket"
rescue ActiveRecord::RecordNotFound
  redirect_to root_path, alert: "You are not authorized to view this receipt or it does not exist."
end
  end
end