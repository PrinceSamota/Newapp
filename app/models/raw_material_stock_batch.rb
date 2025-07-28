class RawMaterialStockBatch < ApplicationRecord
    has_many :raw_material_stock_items, inverse_of: :raw_material_stock_batch
    accepts_nested_attributes_for :raw_material_stock_items, allow_destroy: true
    has_paper_trail save_changes: true
    belongs_to :supplier, optional: true
end
