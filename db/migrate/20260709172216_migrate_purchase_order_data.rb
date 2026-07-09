class MigratePurchaseOrderData < ActiveRecord::Migration[7.2]
  def up
    po_numbers = PurchaseOrder.pluck(:po_number).uniq
    
    po_numbers.each do |po_number|
      pos = PurchaseOrder.where(po_number: po_number).order(:id).to_a
      next if pos.empty?
      
      parent_po = pos.first
      
      pos.each do |po|
        PurchaseOrderItem.create!(
          purchase_order_id: parent_po.id,
          sku_id: po.sku_id,
          item_name: po.item_name,
          quantity: po.quantity,
          purchase_price: po.purchase_price
        )
        
        if po.id != parent_po.id
          RawMaterialStockBatch.where(purchase_order_id: po.id).update_all(purchase_order_id: parent_po.id)
          po.destroy
        end
      end
    end
  end

  def down
    PurchaseOrderItem.delete_all
  end
end
