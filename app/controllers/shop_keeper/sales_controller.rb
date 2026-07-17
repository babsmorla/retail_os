module ShopKeeper
  class SalesController < BaseController
    def index
      # 1. Establish the base scope based on role
      base_scope = current_user.admin? ? Sale.all : current_store.sales

      # 2. Determine Date Range Filter (Prioritize Quick-Period Filter first, then custom date range)
      if params[:period].present?
        @period = params[:period]
        range = case @period
        when "today"      then Time.current.all_day
        when "yesterday"  then 1.day.ago.all_day
        when "this_week"  then Time.current.all_week
        when "this_month" then Time.current.all_month
        else Time.current.all_day
        end
        @sales_scope = base_scope.where(created_at: range)
      elsif params[:start_date].present? || params[:end_date].present?
        @sales_scope = base_scope
        if params[:start_date].present?
          @sales_scope = @sales_scope.where("sales.created_at >= ?", params[:start_date].to_date.beginning_of_day)
        end
        if params[:end_date].present?
          @sales_scope = @sales_scope.where("sales.created_at <= ?", params[:end_date].to_date.end_of_day)
        end
      else
        # Fallback default: show everything or show today's sales
        @sales_scope = base_scope
      end

      # 3. Apply Text Search & Staff Filters
      @sales_scope = @sales_scope.where("receipt_number ILIKE ?", "%#{params[:search].strip}%") if params[:search].present?
      @sales_scope = @sales_scope.where(shop_keeper_id: params[:user_id]) if params[:user_id].present?

      # 4. Calculate Stats (Do this BEFORE pagination or ordering)
      @total_revenue = @sales_scope.sum(:grand_total)
      @total_transactions = @sales_scope.count

      # 5. Fetch, order, and paginate the records for the view
      @sales = @sales_scope.includes(:shop_keeper, :receipt)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(25)

      # 6. Metadata for dropdowns & sidebar metrics
      @today_total = base_scope.where(created_at: Time.current.all_day).sum(:grand_total)
      @monthly_total = base_scope.where(created_at: Time.current.all_month).sum(:grand_total)
      # shop keppers should include the owner
      @shopkeepers = current_store.users.where(role: [ :shop_keeper, :admin ]).order(:full_name)

      respond_to do |format|
        format.html
        format.csv do
          send_data @sales_scope.to_csv, filename: "sales-history-#{Date.today}.csv"
        end
      end
    end

    def success
      @receipt = Receipt.find(params[:receipt_id])
    end

    def new
  @categories = current_store.categories.where(active: true)

  # Fetch active products in active categories
  @products = current_store.products.active.available
                           .joins(:category)
                           .where(categories: { active: true })

  # Apply search and category filters
  @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
  @products = @products.where("LOWER(products.name) LIKE ?", "%#{params[:search].downcase}%") if params[:search].present?

  # --- ADD PAGINATION HERE ---
  @products = @products.page(params[:page]).per(12)

  @sale = current_store.sales.build
end

    def create
  if current_store.nil?
    redirect_to root_path, alert: "No active store selected. Please select a store."
    return
  end

  @sale = current_store.sales.build(sale_params)
  @sale.store_id = current_store.id
  @sale.shop_keeper_id = current_user.id

  # Start a begin block here to monitor the save attempt
  begin
    save_and_confirm_sale
  rescue ActiveRecord::RecordNotUnique
    # Reset the duplicate receipt number so the before_validation callback
    # runs again to generate a fresh, unique suffix (e.g. RS-20260717062414-XXXX)
    @sale.receipt_number = nil

    # Try one more time with the new unique suffix
    save_and_confirm_sale
  end
end

    private

    def save_and_confirm_sale
  if @sale.save
    begin
      receipt = Sales::ConfirmSaleService.new(@sale, current_store).call
      redirect_to success_shop_keeper_sales_path(receipt_id: receipt.id), notice: "Sale completed."
    rescue => e
      Rails.logger.error "Sale Confirmation Failed: #{e.message}"
      redirect_to new_shop_keeper_sale_path, alert: "Error confirming sale: #{e.message}"
    end
  else
    Rails.logger.error "SALE INVALID: #{@sale.errors.full_messages}"

    # Re-populate local variables for the render fallback
    @categories = current_store.categories.where(active: true)
    @products = current_store.products.active.available
                             .joins(:category)
                             .where(categories: { active: true })
    render :new, status: :unprocessable_entity
  end
  end

    def sale_params
      params.require(:sale).permit(
        :payment_method,
        sale_items_attributes: [ :product_id, :quantity, :unit_price_at_sale ]
      )
    end
  end
end
