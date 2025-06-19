class ItemMaster < ApplicationRecord
  has_many :boms, dependent: :destroy
  has_many :bom_raw_materials, dependent: :destroy
  belongs_to :category
  belongs_to :measurement
  before_create :generate_sku_id

  private

  def generate_sku_id
    last_number = ItemMaster.maximum(:id).to_i + 1
    self.sku_id = "SKU#{last_number.to_s.rjust(5, '0')}"
  end
end
