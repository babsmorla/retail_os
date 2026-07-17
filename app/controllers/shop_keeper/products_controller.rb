module ShopKeeper
  class ProductsController < BaseController
    before_action :authenticate_admin!, only: [ :edit, :update, :destroy, :create, :new, :archived, :restore ]
    before_action :set_product, only: [ :edit, :update, :destroy ]

    def index
      # Use .active to only show products where active is true (assuming you added the scope)

      if current_store.nil?
    flash[:alert] = "Please select a store to proceed."
    redirect_to access_denied_path and return
      end

      @products = current_store.products.active
      @products = @products.where("name ILIKE ? OR sku ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
      @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?

      respond_to do |format|
        format.html
        format.csv { send_data @products.to_csv, filename: "inventory-#{Date.today}.csv" }
      end
    end

    def new
     @product = current_store.products.build
      @categories = current_store.categories # Scope to store!
    end

    def create
  # Ensure we are building the product through the current_store association
  @product = current_store.products.build(product_params)

  # Ensure the store_id is set explicitly if build doesn't handle it
  @product.store_id = current_store.id if @product.store_id.nil?

  if @product.save
    redirect_to shop_keeper_products_path, notice: "Product created successfully."
  else
    @categories = current_store.categories
    render :new, status: :unprocessable_entity
  end
end

    def edit
      @categories = current_store.categories
    end

    def update
      if @product.update(product_params)
        redirect_to shop_keeper_products_path, notice: "Product updated successfully."
      else
        @categories = Category.all
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
  # Check if we can find the product first
  @product = Product.find(params[:id])

  if @product.update(active: false)
    redirect_to shop_keeper_products_path, notice: "Product deactivated successfully."
  else
    # This flashes the EXACT reason why the database update failed
    redirect_to shop_keeper_products_path, alert: "Errors: #{@product.errors.full_messages.join(', ')}"
  end
end


def archived
  @products = Product.where(active: false)
end

def restore
  @product = Product.find(params[:id])
  if @product.update(active: true)
    redirect_to archived_shop_keeper_products_path, notice: "Product restored successfully."
  else
    redirect_to archived_shop_keeper_products_path, alert: "Could not restore product."
  end
end

    private



    def set_product
      @product = current_store.products.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to shop_keeper_products_path, alert: "Product not found."
    end

    # Moved these inside the class
    def authenticate_admin!
      unless current_user&.admin?
        redirect_to shop_keeper_products_path, alert: "Access denied. Admins only."
      end
    end

    def product_params
  params.require(:product).permit(
    :name,
    :sku,
    :category_id,
    :cost_price,
    :unit_price,
    :quantity_on_hand,
    :reorder_level
  )
end
  end
end
