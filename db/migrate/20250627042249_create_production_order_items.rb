class CreateProductionOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :production_order_items do |t|
      t.references :production_order, null: false, foreign_key: true
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
