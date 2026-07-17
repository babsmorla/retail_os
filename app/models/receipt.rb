class Receipt < ApplicationRecord

  belongs_to :sale
belongs_to :store

  validates :sale,
            presence: true


end