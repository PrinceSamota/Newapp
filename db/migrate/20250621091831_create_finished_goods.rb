class CreateFinishedGoods < ActiveRecord::Migration[7.2]
  def change
    create_table :finished_goods do |t|
      t.integer :bill_of_material_id
      t.string :item_name
      t.float :quantity
      t.string :sku_id
      t.string :unit

      t.timestamps
    end
  end
end
