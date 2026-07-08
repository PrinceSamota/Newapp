class AddPurchaseOrderIdToRawMaterialInwards < ActiveRecord::Migration[7.2]
  def change
    add_column :raw_material_inwards, :purchase_order_id, :integer
  end
end
