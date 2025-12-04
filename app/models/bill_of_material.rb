require "csv"
class BillOfMaterial < ApplicationRecord
  has_one :finished_good, dependent: :destroy
  has_many :bom_raw_material_items, dependent: :destroy
  has_many :production_order_items
  accepts_nested_attributes_for :finished_good
  accepts_nested_attributes_for :bom_raw_material_items, allow_destroy: true
  
  before_create :generate_bom_number, if: -> { bom_number.blank? }

  has_paper_trail save_changes: true
  validates_associated :finished_good
  validates_associated :bom_raw_material_items
  
  def generate_bom_number
    last_bom = BillOfMaterial.maximum(:bom_number)
    last_number = last_bom ? last_bom.delete("BOM").to_i : 0
    self.bom_number = "BOM#{(last_number + 1).to_s.rjust(5, '0')}"
  end

  def self.ransackable_attributes(auth_object = nil)
    ["bom_number", "bom_tag", "created_at", "flag", "id", "name", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      finished_good
    ]
  end

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["BOM Number", "BOM Name", "Finished Good"]
  
      all.each do |item|
        csv << [
          item.bom_number,
          item.name,
          item.finished_good&.sku_id
        ]
      end
    end
  end

  private

  def must_have_at_least_one_raw_material
    if bom_raw_material_items.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "At least one raw material is required")
    end
  end
end