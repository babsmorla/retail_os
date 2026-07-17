class AddBalanceAfterToStockMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :stock_movements, :balance_after, :integer
  end
end
