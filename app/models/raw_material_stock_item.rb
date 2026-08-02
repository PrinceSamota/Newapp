class RawMaterialStockItem < ApplicationRecord
  belongs_to :raw_material_stock_batch
  belongs_to :item_master, optional: true

  before_validation :assign_item_master_id
  
  attr_accessor :po_remaining_quantity

  after_save :update_purchase_order_status
  after_destroy :update_purchase_order_status

  validate :receiving_quantity_cannot_exceed_po_remaining, if: -> { raw_material_stock_batch&.purchase_order_id.present? }

  private

  def receiving_quantity_cannot_exceed_po_remaining
    po = raw_material_stock_batch.purchase_order
    po_item = po.purchase_order_items.find_by(sku_id: sku_id)
    
    if po_item
      total_ordered = po_item.quantity
      other_received = RawMaterialStockItem.joins(:raw_material_stock_batch)
                                           .where(raw_material_stock_batches: { purchase_order_id: po.id })
                                           .where(sku_id: sku_id)
                                           .where.not(id: id)
                                           .sum(:receiving_quantity)
      available_to_receive = total_ordered - other_received
      
      if receiving_quantity.to_i > available_to_receive
        errors.add(:receiving_quantity, "cannot exceed remaining PO quantity (#{available_to_receive}) for #{sku_id}")
      end
    end
  end

  def assign_item_master_id
    Rails.logger.debug "assign_item_master_id running for sku_id=#{sku_id}, item_name=#{item_name}"
    return unless item_master_id.blank?

    item = ItemMaster.find_by(sku_id: sku_id) || ItemMaster.find_by(item_name: item_name)
    if item
      self.item_master_id = item.id
      Rails.logger.debug " Matched ItemMaster ##{item.id}"
    else
      Rails.logger.debug "No ItemMaster found for sku_id=#{sku_id} or item_name=#{item_name}"
    end
  end

  def update_purchase_order_status
    po = raw_material_stock_batch&.purchase_order
    po&.update_status_based_on_items!
  end
end
