require "csv"
class ItemMaster < ApplicationRecord
  has_many :boms, dependent: :destroy
  has_many :bom_raw_material_items, dependent: :destroy
  has_many :raw_material_stock_items
  has_many :order_entries
  has_many :production_order_items
  has_many :production_orders

  belongs_to :category
  belongs_to :measurement

  belongs_to :fuse_type, optional: true
  belongs_to :loop, optional: true
  belongs_to :item_type, optional: true
  belongs_to :profile, optional: true
  belongs_to :wattage, optional: true
  belongs_to :voltage, optional: true
  belongs_to :length, optional: true
  belongs_to :cct, optional: true
  belongs_to :cover_type, optional: true
  belongs_to :extra, optional: true

  has_one :finished_good, primary_key: :sku_id
  has_one :bill_of_material, through: :finished_good

  has_paper_trail save_changes: true, meta: { reason: :paper_trail_reason }
  validates :item_name, presence: true, unless: :is_bom?
  validates :opening_stock, :purchase_price, :sale_price, :minimum_stock_level, presence: true
  validates :category_id, :measurement_id, presence: true

  with_options if: :is_bom? do
    validates :article_number, presence: true
    validates :fuse_type_id, :loop_id, :item_type_id, :profile_id, :wattage_id,
              :voltage_id, :length_id, :cct_id, :cover_type_id,
              presence: true
  end

  before_create :generate_sku_id, if: -> { sku_id.blank? }
  before_validation :generate_item_name, if: -> { is_bom == true && item_name.blank? }

  def self.to_csv
    CSV.generate(headers: true) do |csv|
      csv << ["SKU", "Item Name", "Category", "Stock", "Purchase Price", "Sale Price", "Min Stock", "Is BOM", "Extra", "Article No", "Measurement"]
  
      all.each do |item|
        csv << [
          item.sku_id,
          item.item_name,
          item.category&.name,
          item.opening_stock,
          item.purchase_price,
          item.sale_price,
          item.minimum_stock_level,
          item.is_bom ? "Yes" : "No",
          item.extra&.name,
          item.article_number,
          item.measurement&.name
        ]
      end
    end
  end

  private

  def paper_trail_reason
    PaperTrail.request.controller_info[:reason] if PaperTrail.request.controller_info
  end


  def generate_sku_id
    last_number = ItemMaster.pluck(:sku_id).map { |sku| sku.delete("SKU").to_i }.max || 0
    self.sku_id = "SKU#{(last_number + 1).to_s.rjust(5, '0')}"
  end

  def generate_item_name
    self.item_name = [
      item_type&.name,
      profile&.name,
      voltage&.name,
      wattage&.name,
      length&.name,
      cct&.name,
      cover_type&.name,
      fuse_type&.name,
      extra&.name
    ].compact.join("_")
  end


  def self.ransackable_attributes(auth_object = nil)
    %w[item_name sku_id category article_number]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category sku_id]
  end
end
