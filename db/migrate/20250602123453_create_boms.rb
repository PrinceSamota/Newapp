class CreateBoms < ActiveRecord::Migration[7.2]
  def change
    create_table :boms do |t|
      t.string :bom_number
      t.integer :item_master_id
      t.string :sku_id                
      t.integer :quantity
      t.string :unit
      t.integer :org_id

      t.timestamps
    end
  end
end
