class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false

      t.text :description

      t.string :icon

      t.string :color

      t.boolean :active,
                default: true,
                null: false

      t.integer :category_type,
                 default: 0

      t.timestamps
    end
  end
end
