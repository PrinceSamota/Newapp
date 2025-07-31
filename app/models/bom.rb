class Bom < ApplicationRecord
  belongs_to :item_master
  has_many :bom_raw_materials, dependent: :destroy
  before_create :generate_bom_number

  private

  def generate_bom_number
    last_number = Bom.maximum(:sku_id).delete("SKU").to_i + 1
    self.bom_number = "BOM#{last_number.to_s.rjust(5, '0')}"
  end
end

