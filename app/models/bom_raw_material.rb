class BomRawMaterial < ApplicationRecord
  belongs_to :bom

  validates :raw_material_sku, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
