class AddStoreToReceipts < ActiveRecord::Migration[8.1]
  def change
  add_reference :receipts, :store, foreign_key: true
  end
end
