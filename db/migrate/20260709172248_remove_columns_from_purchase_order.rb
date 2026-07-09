class RemoveColumnsFromPurchaseOrder < ActiveRecord::Migration[7.2]
  def change
    remove_column :purchase_orders, :sku_id, :string
    remove_column :purchase_orders, :item_name, :string
    remove_column :purchase_orders, :quantity, :integer
    remove_column :purchase_orders, :purchase_price, :float
    remove_column :purchase_orders, :delivered_quantity, :integer
  end
end
