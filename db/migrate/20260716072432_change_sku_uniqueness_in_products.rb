class ChangeSkuUniquenessInProducts < ActiveRecord::Migration[8.1]
 def change
    # Remove the global index (replace 'index_products_on_sku' with your actual index name)
    remove_index :products, :sku
    
    # Add a scoped index
    add_index :products, [:sku, :store_id], unique: true
  end
end
