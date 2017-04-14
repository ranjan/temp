class CreateProperties < ActiveRecord::Migration[5.0]
  def change
    create_table :properties do |t|
      t.string :property_type
      t.string :price
      t.string :address
      t.string :url
      t.integer :property_address_id

      t.timestamps
    end
  end
end
