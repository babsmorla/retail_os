# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  layout "auth"
  
  before_action :configure_sign_up_params, only: [:create]

  def new
    build_resource({})
    yield resource if block_given?
    render "users/registrations/new"
  end

  protected

  # THIS REDIRECTS THE USER TO THEIR DASHBOARD AFTER CREATING THEIR STORE!
  def after_sign_up_path_for(resource)
    flash[:notice] = "Welcome! Your account has been created, and your store is ready to manage."
    shop_keeper_dashboard_path
  end

  # Build the membership and the nested store record in memory
  def build_resource(hash = {})
    super
    if resource.memberships.empty?
      membership = resource.memberships.build
      membership.build_store
    end
  end

  # Allow the nested parameters through Devise's sanitizer
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up) do |user_params|
      user_params.permit(
        :email, 
        :password, 
        :password_confirmation, 
        :full_name,
        memberships_attributes: [
          store_attributes: [:name, :location]
        ]
      )
    end
  end
end