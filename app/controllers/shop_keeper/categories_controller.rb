# app/controllers/shop_keeper/categories_controller.rb
module ShopKeeper
  class CategoriesController < BaseController
    before_action :set_category, only: [:edit, :update, :destroy, :show]

    def index
  # Start with all categories in your store
  @categories = current_store.categories

  # Apply search query if present
  if params[:search].present?
    # Prefix "name" and "description" with "categories." to resolve ambiguity
    @categories = @categories.where(
      "LOWER(categories.name) LIKE :query OR LOWER(categories.description) LIKE :query", 
      query: "%#{params[:search].downcase}%"
    )
  end

  # Eager load products to prevent N+1 queries when counting sub-items
  @categories = @categories.includes(:products).page(params[:page]).per(10)
end
    def new
      @category = current_store.categories.build
    end

    def create
      @category = current_store.categories.build(category_params)
      
      if @category.save
        redirect_to shop_keeper_categories_path, notice: "Category created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
      # Render edit form (automatically handled by Rails via edit.html.erb)
    end

    def update
      if @category.update(category_params)
        redirect_to shop_keeper_categories_path, notice: "Category updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @category.destroy
      redirect_to shop_keeper_categories_path, notice: "Category deleted successfully."
    end

    private

    def set_category
      @category = current_store.categories.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :description, :icon, :color, :category_type, :active)
    end
  end
end