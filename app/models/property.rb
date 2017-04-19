class Property < ApplicationRecord
  has_one :property_detail, dependent: :destroy
end
