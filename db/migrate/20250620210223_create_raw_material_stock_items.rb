class CreateRawMaterialStockItems < ActiveRecord::Migration[7.2]
  def change
    create_table :raw_material_stock_items do |t|
      t.integer :raw_material_stock_batch_id
      t.string :item_name
      t.string :sku_id
      t.integer :receiving_quantity
      t.decimal :purchase_price
      t.integer :item_master_id
      t.timestamps
    end
  end
end
