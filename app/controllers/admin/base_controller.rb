# app/controllers/admin/base_controller.rb
class Admin::BaseController < ShopKeeper::BaseController
  # Since we inherit from ShopKeeper::BaseController, we already have:
  # - :authenticate_user!
  # - :ensure_store_selected
  # - :set_current_store
  # - :resolve_layout

  # We just add one extra filter to ensure ONLY admins can access this area
  before_action :authenticate_admin!
end