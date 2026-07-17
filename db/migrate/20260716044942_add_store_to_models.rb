class AddStoreToModels < ActiveRecord::Migration[8.1]
  def change
   add_column :products, :store_id, :bigint
    add_column :sales, :store_id, :bigint
    add_column :categories, :store_id, :bigint
    
    add_index :products, :store_id
    add_index :sales, :store_id
    add_index :categories, :store_id
  end
end
