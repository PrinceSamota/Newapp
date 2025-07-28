class CreateItemMasters < ActiveRecord::Migration[7.2]
  def change
    create_table :item_masters do |t|
      t.string :item_name
      t.integer :opening_stock
      t.decimal :purchase_price
      t.decimal :sale_price
      t.boolean :is_bom
      t.string :sku_id
      t.string :article_number
      t.integer :minimum_stock_level
      t.integer :category_id
      t.integer :measurement_id
      t.integer :fuse_type_id
      t.integer :loop_id
      t.integer :item_type_id
      t.integer :profile_id
      t.integer :wattage_id
      t.integer :voltage_id
      t.integer :length_id
      t.integer :cct_id
      t.integer :cover_type_id
      t.integer :extra_id
      t.integer :org_id
      t.timestamps
    end
  end
end
