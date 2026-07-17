class AddConfirmedAtToSales < ActiveRecord::Migration[8.1]
  def change
    add_column :sales, :confirmed_at, :datetime
  end
end
