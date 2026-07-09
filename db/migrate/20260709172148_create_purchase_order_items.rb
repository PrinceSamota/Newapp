class CreatePurchaseOrderItems < ActiveRecord::Migration[7.2]
  def change
    create_table :purchase_order_items do |t|
      t.references :purchase_order, null: false, foreign_key: true
      t.string :sku_id
      t.string :item_name
      t.integer :quantity
      t.float :purchase_price

      t.timestamps
    end
  end
end
