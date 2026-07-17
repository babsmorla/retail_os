class CreateReceipts < ActiveRecord::Migration[8.0]
  def change
    create_table :receipts do |t|
      t.references :sale,
                   null: false,
                   foreign_key: true


      t.datetime :printed_at


      t.integer :reprint_count,
                default: 0,
                null: false


      t.timestamps
    end
  end
end
