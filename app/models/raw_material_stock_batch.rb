class RawMaterialStockBatch < ApplicationRecord
    has_many :raw_material_stock_items, inverse_of: :raw_material_stock_batch
    accepts_nested_attributes_for :raw_material_stock_items, allow_destroy: true
    validates :supplier_name, presence: true
    validates :receiving_date, presence: true
    validates :supplier_invoice_number, presence: true
end
