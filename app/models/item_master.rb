class ItemMaster < ApplicationRecord
  has_many :boms, dependent: :destroy
  has_many :bom_raw_material_items, dependent: :destroy
  has_many :raw_material_stock_items
  belongs_to :category
  belongs_to :measurement
  before_create :generate_sku_id
  belongs_to :fuse_type, optional: true
  belongs_to :loop, optional: true
  belongs_to :item_type, optional: true
  belongs_to :profile, optional: true
  belongs_to :wattage, optional: true
  belongs_to :voltage, optional: true
  belongs_to :length, optional: true
  belongs_to :cct, optional: true
  belongs_to :cover_type, optional: true
  has_paper_trail save_changes: true

  private

  def generate_sku_id
    last_number = ItemMaster.maximum(:id).to_i + 1
    self.sku_id = "SKU#{last_number.to_s.rjust(5, '0')}"
  end
end
