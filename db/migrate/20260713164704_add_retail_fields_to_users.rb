class AddRetailFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :role, :integer, default: 0, null: false
    add_column :users, :active, :boolean, default: true, null: false
    add_column :users, :store_id, :integer

    add_index :users, :role
  end
end
