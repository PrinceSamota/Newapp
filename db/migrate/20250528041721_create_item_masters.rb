class CreateItemMasters < ActiveRecord::Migration[7.2]
  def change
    create_table :item_masters do |t|
      t.string :item_name
      t.integer :opening_stock
      t.integer :purchase_price
      t.integer :sale_price
      t.boolean :is_bOM
      t.string :sku_id
      t.integer :minimum_stock_level
      t.references :category, foreign_key: true
      t.references :measurement, foreign_key: true
      t.integer :org_id
      t.timestamps
    end
  end
end
