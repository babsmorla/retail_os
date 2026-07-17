class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|

      t.string :name, null: false

      t.string :sku

      t.decimal :unit_price,
                precision: 10,
                scale: 2,
                null: false

      t.decimal :cost_price,
                precision: 10,
                scale: 2

      t.integer :quantity_on_hand,
                 default: 0,
                 null: false

      t.integer :reorder_level,
                 default: 5

      t.references :category,
                   foreign_key: true

      t.timestamps
    end


    add_index :products, :sku, unique: true
  end
end