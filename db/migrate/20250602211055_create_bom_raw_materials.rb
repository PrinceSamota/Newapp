class CreateBomRawMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :bom_raw_materials do |t|
      t.references :bom, null: false, foreign_key: true
      t.string :item_master_id
      t.integer :quantity

      t.timestamps
    end
  end
end
