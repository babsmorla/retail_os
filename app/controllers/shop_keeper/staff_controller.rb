module ShopKeeper
  class StaffController < BaseController
 skip_before_action :ensure_shop_keeper! 
    
    # Enforce admin check
    before_action :authenticate_admin!


    def index
      @staff = current_user.employees
    end

    def new
      @user = current_user.employees.build
    end

    def create
  @user = current_user.employees.build(user_params.except(:first_name, :last_name))
  
  # Force the owner_id manually
  @user.owner_id = current_user.id 
  
  # Manual name concatenation
  if params[:user][:first_name].present? || params[:user][:last_name].present?
    @user.full_name = "#{params[:user][:first_name]} #{params[:user][:last_name]}".strip
  end

  if @user.save
    @user.memberships.create!(store: current_store)
    redirect_to shop_keeper_staff_index_path, notice: "Staff member added successfully."
  else
    render :new, status: :unprocessable_entity
  end
end
    private

    # Use one single method for all permitted params
    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email, :password, :role, :phone_number
      )
    end
  end
end