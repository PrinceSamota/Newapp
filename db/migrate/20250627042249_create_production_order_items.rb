class CreateProductionOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :production_order_items do |t|
      t.integer :production_order_id
      t.text :bom_ids
      t.string :sku_id
      t.string :item_name
      t.integer :current_stock
      t.float :quantity
      t.string :bom
      t.string :stage
      
      t.timestamps
    end
  end
end
