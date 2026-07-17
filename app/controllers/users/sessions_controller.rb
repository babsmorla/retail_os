module Users
  class SessionsController < Devise::SessionsController
    layout "auth"
    skip_before_action :set_current_store, raise: false

    before_action :redirect_if_authenticated, only: %i[new create]

    def new
      super
    end

    def create
      self.resource = warden.authenticate(auth_options)

      if resource
        sign_in(resource_name, resource)

        flash[:notice] = "Welcome back, #{resource.full_name}!"

        redirect_to after_sign_in_path_for(resource)
      else
        flash.now[:alert] = "Invalid email or password."
        self.resource = resource_class.new(sign_in_params)

        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      flash[:notice] = "Signed out successfully."

      super
    end

    protected

    def after_sign_in_path_for(resource)
      case resource.role
      when "admin"
        shop_keeper_dashboard_path

      when "shop_keeper"
         shop_keeper_dashboard_path

      when "inventory_officer"
        shop_keeper_dashboard_path

      else
        demo_index_path
      end
    end

   def after_sign_out_path_for(resource_or_scope)
  login_path
end

    private

    def redirect_if_authenticated
      redirect_to after_sign_in_path_for(current_user) if user_signed_in?
    end
  end
end