class CreateFinishedGoods < ActiveRecord::Migration[7.2]
  def change
    create_table :finished_goods do |t|
      t.references :bill_of_material, null: false, foreign_key: true
      t.string :item_name
      t.integer :quantity
      t.string :sku_id
      t.integer :unit

      t.timestamps
    end
  end
end
