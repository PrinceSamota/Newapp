class AddPurchaseOrderIdToRawMaterialStockBatches < ActiveRecord::Migration[7.2]
  def change
    add_column :raw_material_stock_batches, :purchase_order_id, :integer
  end
end
