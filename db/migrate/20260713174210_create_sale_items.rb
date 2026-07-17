class CreateSaleItems < ActiveRecord::Migration[8.0]
  def change
    create_table :sale_items do |t|

      t.references :sale,
                   null: false,
                   foreign_key: true


      t.references :product,
                   null: false,
                   foreign_key: true


      t.integer :quantity,
                null: false


      t.decimal :unit_price_at_sale,
                precision: 10,
                scale: 2


      t.decimal :line_total,
                precision: 10,
                scale: 2


      t.timestamps
    end
  end
end