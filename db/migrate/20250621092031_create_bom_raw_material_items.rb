class CreateBomRawMaterialItems < ActiveRecord::Migration[7.2]
  def change
    create_table :bom_raw_material_items do |t|
      t.integer :bill_of_material_id
      t.string :item_name
      t.float :quantity
      t.string :sku_id
      t.string :unit

      t.timestamps
    end
  end
end
