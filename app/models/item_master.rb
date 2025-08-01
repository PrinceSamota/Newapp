class ItemMaster < ApplicationRecord
  has_many :boms, dependent: :destroy
  has_many :bom_raw_material_items, dependent: :destroy
  has_many :raw_material_stock_items
  belongs_to :category
  belongs_to :measurement
  before_create :generate_sku_id, if: -> { sku_id.blank? }
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
  has_paper_trail save_changes: true
  has_many :production_order_items
  has_many :production_orders
  validates :item_name, presence: true
  validates :opening_stock, presence: true
  validates :purchase_price, presence: true
  validates :sale_price, presence: true
  validates :minimum_stock_level, presence: true
  has_one :finished_good, foreign_key: :sku_id, primary_key: :sku_id
  has_one :bill_of_material, through: :finished_good
  # BOM-specific validations
  with_options if: :is_bom? do
    validates :article_number, presence: true
    validates :fuse_type_id, :loop_id, :item_type_id, :profile_id, :wattage_id,
              :voltage_id, :length_id, :cct_id, :cover_type_id, 
              presence: true
  end

  validates :category_id, :measurement_id, presence: true
  before_validation :generate_item_name, if: -> { is_bom == true && self.item_name.blank? }
  private

  def generate_sku_id
    last_number = ItemMaster.maximum(:sku_id).delete("SKU").to_i + 1
    self.sku_id = "SKU#{last_number.to_s.rjust(5, '0')}"
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      item_name
      sku_id
      category
      article_number
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[
      category
      sku_id
    ]
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
      extra&.name,
    ].compact.join("_")
  end

end
