class BillOfMaterial < ApplicationRecord
    has_one :finished_good, dependent: :destroy
    has_many :bom_raw_material_items, dependent: :destroy
  
    accepts_nested_attributes_for :finished_good
    accepts_nested_attributes_for :bom_raw_material_items, allow_destroy: true
  
    before_create :generate_bom_number
  
    def generate_bom_number
      last_number = BillOfMaterial.maximum(:id).to_i + 1
      self.bom_number = "BOM#{last_number.to_s.rjust(5, '0')}"
    end
  end