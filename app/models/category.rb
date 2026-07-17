class Category < ApplicationRecord
  belongs_to :store
  has_many :products, dependent: :nullify
  before_destroy :reassign_products_to_fallback

  # Allows nesting of child products/services on creation
  accepts_nested_attributes_for :products, allow_destroy: true, reject_if: :all_blank

  enum :category_type, {
    product: 0,
    service: 1
  }

  validates :name, presence: true

  scope :active, -> { where(active: true) }

  private

  def reassign_products_to_fallback
    # Find or create a default 'Uncategorized' category for this store
    fallback_category = store.categories.find_or_create_by!(name: "Uncategorized") do |cat|
      cat.color = "slate"
      cat.icon = "layers"
      cat.active = true
    end

    # Update all products belonging to this category to the fallback category
    products.update_all(category_id: fallback_category.id)
  end
end
