class AddStoreToStockMovements < ActiveRecord::Migration[8.1]
  def change
    add_column :stock_movements, :store_id, :bigint
    add_index :stock_movements, :store_id
  end
end
