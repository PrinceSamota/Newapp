class CreatePurchaseOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :purchase_orders do |t|
      t.string :po_number
      t.date :po_date
      t.string :supplier_name
      t.string :sku_id
      t.string :item_name
      t.integer :quantity
      t.float :purchase_price
      t.integer :delivered_quantity, default: 0
      t.string :status, default: 'Open'

      t.timestamps
    end
  end
end
