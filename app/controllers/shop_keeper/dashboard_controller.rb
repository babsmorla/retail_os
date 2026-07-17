module ShopKeeper
   class DashboardController < BaseController

   def index
      # 1. Today's Sales (Scoped to current user and inner joined on receipts to be safe)
      today_sales = current_user.sales
                                .joins(:receipt)
                                .where(created_at: Time.current.all_day)

      # Today's Sales Count
      @today_sales_count = today_sales.count

      # Today's Revenue
      @today_revenue = today_sales.sum(:grand_total)

      @today_revenue_formatted = helpers.number_to_currency(
        @today_revenue,
        unit: "GHS ",
        precision: 2
      )

      # 2. Recent Receipts (Inner join on :receipt guarantees no nil values can crash the view link_to)
      @recent_receipts = current_user.sales
                                     .joins(:receipt)
                                     .includes(:receipt, :sale_items)
                                     .order(created_at: :desc)
                                     .limit(5)

      # 3. Recent Transactions (Eager load receipt to prevent N+1 queries)
      @recent_transactions = current_user.sales
                                         .includes(:receipt, :sale_items)
                                         .order(created_at: :desc)
                                         .limit(5)

      # 4. Low Stock Products (System wide check)
      @low_stock_products = Product.where("quantity_on_hand <= low_stock_threshold")
      @low_stock_count = @low_stock_products.count
    end


    

  end
end