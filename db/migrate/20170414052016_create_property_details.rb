class CreatePropertyDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :property_details do |t|
      t.string :area
      t.string :address
      t.text :description
      t.string :facts
      t.string :market_value
      t.integer :property_id

      t.timestamps
    end
  end
end
