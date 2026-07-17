class CreateSales < ActiveRecord::Migration[8.0]
  def change
    create_table :sales do |t|

      t.string :receipt_number,
               null: false

      t.references :shop_keeper,
                   null: false,
                   foreign_key: {
                     to_table: :users
                   }

      t.integer :status,
                default: 0,
                null: false


      t.decimal :subtotal,
                precision: 10,
                scale: 2,
                default: 0


      t.decimal :discount_total,
                precision: 10,
                scale: 2,
                default: 0


      t.decimal :tax_total,
                precision: 10,
                scale: 2,
                default: 0


      t.decimal :grand_total,
                precision: 10,
                scale: 2,
                default: 0


      t.integer :payment_method,
                default: 0


      t.timestamps
    end


    add_index :sales,
              :receipt_number,
              unique: true
  end
end