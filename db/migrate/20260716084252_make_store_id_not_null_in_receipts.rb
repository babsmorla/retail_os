class MakeStoreIdNotNullInReceipts < ActiveRecord::Migration[8.1]
 def change
    change_column_null :receipts, :store_id, false
  end
end
