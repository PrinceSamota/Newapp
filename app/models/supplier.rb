class Supplier < ApplicationRecord
    has_many :raw_material_inward_batches
    has_many :raw_material_stock_batches

    def self.ransackable_attributes(auth_object = nil)
      %w[id name org_id created_at updated_at]
    end
  
    def self.ransackable_associations(auth_object = nil)
      %w[raw_material_inward_batches raw_material_stock_batches]
    end
end
