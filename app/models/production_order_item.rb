class ProductionOrderItem < ApplicationRecord
  belongs_to :production_order
  validates :sku_id, presence: true
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
