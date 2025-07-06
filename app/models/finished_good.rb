class FinishedGood < ApplicationRecord
  belongs_to :bill_of_material
  validates :sku_id, presence: true
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit, presence: true
end
