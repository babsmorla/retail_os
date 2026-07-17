class AddStoreIdToAccountingEntries < ActiveRecord::Migration[8.1]
  def change
   add_reference :accounting_entries, :store, foreign_key: true
  end
end
