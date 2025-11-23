class FinishedGood < ApplicationRecord
  belongs_to :bill_of_material
  belongs_to :item_master, optional: true
  validates :item_master_id, presence: true
  validates :quantity, presence: true
  validates :unit, presence: true
  validates :sku_id, presence: true
  def self.ransackable_attributes(auth_object = nil)
    ["bill_of_material_id", "created_at", "id", "item_name", "quantity", "sku_id", "unit", "updated_at"]
  end
end
