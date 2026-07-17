module ShopKeeper
  class StaffController < BaseController
    skip_before_action :ensure_shop_keeper!
    before_action :authenticate_admin!

    def index
      # 1. Find all user IDs linked to this store through memberships
      staff_ids = Membership.where(store_id: current_store.id).pluck(:user_id)

      # 2. Fetch those users, eager-loading memberships and stores to prevent N+1 queries.
      # We exclude the current user so they don't see themselves listed as their own staff.
      @staff = User.where(id: staff_ids)
                   .where.not(id: current_user.id)
                   .includes(memberships: :store)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params.except(:first_name, :last_name))

      # Set the owner_id to the top-level owner.
      # If current_user has an owner, use that; otherwise, current_user IS the owner.
      @user.owner_id = current_user.owner_id.presence || current_user.id

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

    def user_params
      params.require(:user).permit(
        :first_name, :last_name, :email, :password, :role, :phone_number
      )
    end
  end
end
