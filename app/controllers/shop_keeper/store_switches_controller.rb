# app/controllers/shop_keeper/store_switches_controller.rb
module ShopKeeper
  class StoreSwitchesController < BaseController
    def update
      # Find the store the user wants to switch to
      new_store = current_user.stores.find(params[:id])

      # Update the session so all future requests use this store_id
      session[:store_id] = new_store.id

      redirect_back fallback_location: shop_keeper_dashboard_path,
                    notice: "Switched to #{new_store.name}"
    end
  end
end
