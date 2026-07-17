module ShopKeeper
  class ReportsController < BaseController
    skip_before_action :ensure_shop_keeper!
    before_action :authenticate_admin!
   def index
  # 1. Determine the range
  if params[:specific_date].present?
    # User picked a specific day from the calendar
    selected_date = params[:specific_date].to_date
    range = selected_date.all_day
    @period = "custom"
  else
    # Default to periods if no date picked
    @period = params[:period] || "today"
    range = case @period
    when "today"      then Time.current.all_day
    when "yesterday"  then 1.day.ago.all_day
    when "this_week"  then Time.current.all_week
    when "this_month" then Time.current.all_month
    else Time.current.all_day
    end
  end

  # 2. Filter sales
  @sales = current_store.sales.where(created_at: range).order(created_at: :desc)

  # 3. Apply search if present
  @sales = @sales.where("receipt_number ILIKE ?", "%#{params[:search].strip}%") if params[:search].present?

  @total_revenue = @sales.sum(:grand_total)
  @total_transactions = @sales.count
end
  end
end
