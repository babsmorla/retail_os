class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.integer :movement_type
      t.integer :quantity
      t.string :reference_type
      t.integer :reference_id

      t.timestamps
    end
  end
end
