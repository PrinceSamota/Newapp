class CreateRawMaterialInwards < ActiveRecord::Migration[7.2]
  def change
    create_table :raw_material_inwards do |t|
      t.string :supplier_name
      t.date :receiving_date
      t.string :sku_id
      t.string :item_name
      t.integer :receiving_quantity
      t.float :purchase_price

      t.timestamps
    end
  end
end
