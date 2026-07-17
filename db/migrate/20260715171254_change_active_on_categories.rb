class ChangeActiveOnCategories < ActiveRecord::Migration[8.1]
  def change
    change_column_null :categories, :active, false, true # Sets existing to true
change_column_default :categories, :active, true
  end
end
