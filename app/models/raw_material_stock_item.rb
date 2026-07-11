class RawMaterialStockItem < ApplicationRecord
  belongs_to :raw_material_stock_batch
  belongs_to :item_master, optional: true

  before_validation :assign_item_master_id
  
  attr_accessor :po_remaining_quantity

  private

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
end
