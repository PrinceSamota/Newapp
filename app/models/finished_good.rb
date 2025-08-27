class FinishedGood < ApplicationRecord
  belongs_to :bill_of_material
  belongs_to :item_master, optional: true
  def self.ransackable_attributes(auth_object = nil)
    ["bill_of_material_id", "created_at", "id", "item_name", "quantity", "sku_id", "unit", "updated_at"]
  end
end
