class PropertyAddress < ApplicationRecord
  has_many :properties, dependent: :destroy
end
