class RawMaterialStockBatch < ApplicationRecord
    has_many :raw_material_stock_items, inverse_of: :raw_material_stock_batch
    accepts_nested_attributes_for :raw_material_stock_items, allow_destroy: true
    has_paper_trail save_changes: true
    belongs_to :supplier, optional: true
    delegate :name, to: :supplier, prefix: true, allow_nil: true

    def self.ransackable_attributes(auth_object = nil)
      %w[
        supplier_id
        supplier_invoice_number
        receiving_date
        created_at
        updated_at
        id
      ]
    end
  
    def self.ransackable_associations(auth_object = nil)
      %w[supplier]
    end
end
