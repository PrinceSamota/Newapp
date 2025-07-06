class RawMaterialStockItem < ApplicationRecord
  belongs_to :raw_material_stock_batch
  validates :item_name, presence: true
  validates :sku_id, presence: true
  validates :receiving_quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :purchase_price, presence: true
end
