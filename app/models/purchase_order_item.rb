class PurchaseOrderItem < ApplicationRecord
  belongs_to :purchase_order

  validates :sku_id, :item_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :purchase_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def calculated_delivered_quantity
    RawMaterialStockItem.joins(:raw_material_stock_batch)
                        .where(raw_material_stock_batches: { purchase_order_id: purchase_order_id })
                        .where(sku_id: sku_id)
                        .sum(:receiving_quantity)
  end

  def remaining_quantity
    [quantity - calculated_delivered_quantity, 0].max
  end

  def self.ransackable_attributes(auth_object = nil)
    ["sku_id", "item_name"]
  end
end
