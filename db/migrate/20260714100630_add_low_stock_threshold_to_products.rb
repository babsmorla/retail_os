class AddLowStockThresholdToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :low_stock_threshold, :integer
  end
end
