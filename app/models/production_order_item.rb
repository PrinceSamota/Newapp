class ProductionOrderItem < ApplicationRecord
  belongs_to :production_order
  belongs_to :bill_of_material, optional: true

  def parsed_bom_ids
    JSON.parse(bom_ids || "[]") rescue []
  end

  def boms
    BillOfMaterial.where(id: parsed_bom_ids)
  end
end