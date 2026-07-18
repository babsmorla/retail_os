module ShopKeeper
  class ShopResetsController < BaseController
    skip_before_action :ensure_shop_keeper!
    before_action :authenticate_admin!

    def new
      # Renders the confirmation form (type store name + password).
    end

    def create
      unless current_user.valid_password?(params[:password])
        return redirect_to new_shop_keeper_shop_reset_path, alert: "Incorrect password."
      end

      unless params[:confirmation] == current_store.name
        return redirect_to new_shop_keeper_shop_reset_path,
          alert: "Store name confirmation did not match. Type it exactly as shown."
      end

      ShopResetService.new(store: current_store, admin: current_user).call

      redirect_to shop_keeper_dashboard_path,
        notice: "Shop has been reset. All employees, products, categories, and sales history were cleared. Your account and store details were kept."
    rescue => e
      redirect_to new_shop_keeper_shop_reset_path, alert: "Reset failed: #{e.message}"
    end
  end
end
