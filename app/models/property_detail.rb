class PropertyDetail < ApplicationRecord
  serialize :facts, Hash
  serialize :market_value, Hash
  belongs_to :property
end
