class BomRawMaterial < ApplicationRecord
  belongs_to :bom
  belongs_to :item_master
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
