# app/models/store.rb
class Store < ApplicationRecord
  # 1. ASSOCIATIONS
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  
  has_many :products, dependent: :destroy
  has_many :sales, dependent: :destroy
  has_many :sale_items, through: :sales
  
  has_many :categories, dependent: :destroy
  has_many :accounting_entries, dependent: :destroy
  has_many :stock_movements, dependent: :destroy
  has_many :receipts, dependent: :destroy

  # 2. VALIDATIONS
  # This stops blank ghost records (like ID 4 in your console) from breaking your app
  validates :name, presence: true, length: { minimum: 2 }
  validates :location, presence: true
  before_validation :set_default_active, on: :create

  private

  def set_default_active
    # This safely ensures 'active' is set to true on new stores
    self.active = true if active.nil?
  end
  
end