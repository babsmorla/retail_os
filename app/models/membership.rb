class Membership < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :store

  accepts_nested_attributes_for :store
end
