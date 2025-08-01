class ProductionOrderItem < ApplicationRecord
  belongs_to :production_order
  belongs_to :bill_of_material, optional: true
  belongs_to :item_master
  def parsed_bom_ids
    JSON.parse(bom_ids || "[]") rescue []
  end
  def self.ransackable_attributes(auth_object = nil)
    %w[bom item_master_id quantity sku_id production_order_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[item_master production_order]
  end
  def boms
    BillOfMaterial.where(id: parsed_bom_ids)
  end
end