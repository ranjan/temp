class CreatePropertyAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :property_addresses do |t|
      t.string :address

      t.timestamps
    end
  end
end
