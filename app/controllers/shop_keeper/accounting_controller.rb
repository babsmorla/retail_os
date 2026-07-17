module ShopKeeper
  class AccountingController < BaseController
skip_before_action :ensure_shop_keeper!

    # Enforce admin check
    before_action :authenticate_admin!
    def index
     dashboard = Accounting::DashboardService.new(current_user, current_store)

      # =========================
      # KPI CARDS
      # =========================
      @total_revenue = dashboard.total_revenue
      @today_revenue = dashboard.today_sales
      @cash_sales = dashboard.cash_sales
      @mobile_money_sales = dashboard.mobile_money_sales
      @card_sales = dashboard.card_sales

      # =========================
      # FINANCIAL SUMMARY
      # =========================
      @today_sales = dashboard.today_sales
      @today_expenses = dashboard.today_expenses
      @today_profit = dashboard.today_profit

      @monthly_sales = dashboard.monthly_sales
      @monthly_expenses = dashboard.monthly_expenses
      @monthly_profit = dashboard.monthly_profit

      # =========================
      # BALANCE
      # =========================
      @cash_balance = dashboard.cash_balance
      @bank_balance = dashboard.bank_balance

      # =========================
      # TRANSACTIONS (PAGINATED FIX)
      # =========================
      # Apply Kaminari pagination here. Change .per(10) to whatever limit you prefer.
      @recent_sales = dashboard.recent_sales.order(created_at: :desc).limit(5)

      @recent_activity = dashboard.recent_activity

      # =========================
      # PRODUCTS
      # =========================
      @top_products = dashboard.top_products

      # =========================
      # CHART DATA
      # =========================
      chart = dashboard.revenue_chart

      @revenue_chart = {
        labels: chart.keys.map { |date| date.strftime("%b %Y") },
        values: chart.values.map(&:to_f)
      }
    end
  end
end
