class CreateBomRawMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :bom_raw_materials do |t|
      t.integer :bom_id
      t.string :item_master_id
      t.float :quantity

      t.timestamps
    end
  end
end
