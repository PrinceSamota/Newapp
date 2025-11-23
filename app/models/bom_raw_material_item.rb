class BomRawMaterialItem < ApplicationRecord
  belongs_to :bill_of_material
  belongs_to :item_master
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :item_master_id, presence: true
  validates :unit, presence: true
  validates :sku_id, presence: true
end
