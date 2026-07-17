class CreateAccountingEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_entries do |t|
      t.integer :entry_type,
                default: 0,
                null: false


      t.references :reference,
                   polymorphic: true,
                   null: false


      t.decimal :amount,
                precision: 12,
                scale: 2,
                null: false


      t.text :description


      t.timestamps
    end
  end
end
