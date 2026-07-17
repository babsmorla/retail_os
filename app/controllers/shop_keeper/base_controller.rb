# app/controllers/shop_keeper/base_controller.rb
module ShopKeeper
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_shop_keeper!
    before_action :ensure_store_selected
    before_action :set_current_store

    layout :resolve_layout

    # Any controller inheriting from this can use this to restrict actions to admins
    def authenticate_admin!
      unless current_user&.admin?
        raise ActiveRecord::RecordNotFound # Secure 404 masking instead of a redirect!
      end
    end

    private

    def ensure_store_selected
      if current_store.nil? && !current_user.admin?
        redirect_to root_path, alert: "Please select a store to continue."
      end
    end

    def resolve_layout
      if current_user&.admin?
        "application"
      else
        "shop_keeper"
      end
    end

    def set_current_store
      store_id = session[:store_id] || current_user.stores.first&.id
      @current_store = Store.find_by(id: store_id)
      Current.store_id = @current_store&.id
    end

    def ensure_shop_keeper!
      return if current_user.admin?
      return if current_user.shop_keeper?

      redirect_to root_path, alert: "Access denied."
    end
  end
end