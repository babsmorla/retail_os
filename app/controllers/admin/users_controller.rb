module Admin
  class UsersController < ShopKeeper::BaseController
    # Skip the general shop-keeper restriction
    skip_before_action :ensure_shop_keeper!
    
    # Run the admin-only restriction instead
    before_action :authenticate_admin!

    def index
      @users = User.all
    end

    def new
      @user = User.new
    end

    # app/controllers/admin/users_controller.rb
def create
  @user = User.new(user_params)
  
  # Combine first/last name from the form into the database column
  if params[:user][:first_name].present? || params[:user][:last_name].present?
    @user.full_name = "#{params[:user][:first_name]} #{params[:user][:last_name]}".strip
  end

  @user.store_id = current_user.store_id if current_user.store_id.present?
  
  if @user.save
    redirect_to admin_users_path, notice: "User created successfully."
  else
    # Debugging: This will show you exactly why it's failing
    puts @user.errors.full_messages
    render :new, status: :unprocessable_entity
  end
end

private

def user_params
  # Remove :first_name, :last_name, and :username as they aren't in the DB
 params.require(:user).permit(:full_name, :email, :password, :role, :phone_number)
end
  
  end
end