class CreateOrderEntries < ActiveRecord::Migration[7.2]
  def change
    create_table :order_entries do |t|
      t.string :order_no
      t.string :article_no
      t.string :client_id
      t.date :target_date
      t.string :ship_to_location
      t.integer :qty
      t.string :sku_number
      t.string :fuse_type
      t.string :loop
      t.string :item_type
      t.string :profile
      t.string :wattage
      t.string :voltage
      t.string :length
      t.string :cct
      t.string :cover_type
      t.timestamps
    end
  end
end
