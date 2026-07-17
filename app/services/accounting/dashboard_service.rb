module Accounting
  class DashboardService
    def initialize(user, store)
      @user = user
      @store = store
    end

    private
    attr_reader :user, :store

    # Helper methods to automatically scope queries to the specific store
    def sales
      store.sales
    end

    def accounting_entries
      store.accounting_entries
    end

    def sale_items
      store.sale_items
    end

    public

    # ==================================
    # SALES SUMMARY
    # ==================================
    def total_revenue
      sales.sum(:grand_total)
    end

    def today_sales
      sales.where(created_at: Date.current.all_day).sum(:grand_total)
    end

    # Alias to match your controller's old naming convention
    def today_sales_total
      today_sales
    end

    def monthly_sales
      sales.where(created_at: Date.current.all_month).sum(:grand_total)
    end

    # ==================================
    # PAYMENT METHODS
    # ==================================
    def cash_sales
      sales.where(payment_method: :cash).sum(:grand_total)
    end

    def mobile_money_sales
      sales.where(payment_method: :mobile_money).sum(:grand_total)
    end

    def card_sales
      sales.where(payment_method: :card).sum(:grand_total)
    end

    # ==================================
    # EXPENSES
    # ==================================
    def today_expenses
      accounting_entries
        .where(entry_type: [:restock_cost, :adjustment])
        .where(created_at: Date.current.all_day)
        .sum(:amount)
    end

    def monthly_expenses
      accounting_entries
        .where(entry_type: [:restock_cost, :adjustment])
        .where(created_at: Date.current.all_month)
        .sum(:amount)
    end

    # ==================================
    # PROFIT
    # ==================================
    def today_profit
      today_sales - today_expenses
    end

    def monthly_profit
      monthly_sales - monthly_expenses
    end

    # ==================================
    # TRANSACTIONS
    # ==================================
    def recent_sales
      sales.includes(:receipt).order(created_at: :desc).limit(10)
    end

    def recent_activity
      recent_sales
    end

    # ==================================
    # TOP PRODUCTS
    # ==================================
    def top_products
      sale_items
        .joins(:product)
        .group("products.name")
        .sum(:quantity)
        .sort_by { |_, qty| -qty }
        .first(5)
    end

    # ==================================
    # BALANCES
    # ==================================
    def cash_balance
      cash_sales
    end

    def bank_balance
      0
    end

    # ==================================
    # CHART DATA
    # ==================================
    def revenue_chart
      sales_data = sales
        .where(created_at: 12.months.ago..Time.current)
        .group("DATE_TRUNC('month', created_at)")
        .sum(:grand_total)

      months = {}
      12.times do |i|
        month = i.months.ago.beginning_of_month
        months[month] = sales_data.select { |date, _| date.month == month.month }.values.sum
      end
      months
    end
  end
end