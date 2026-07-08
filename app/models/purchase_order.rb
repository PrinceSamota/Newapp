class PurchaseOrder < ApplicationRecord
  has_many :raw_material_inwards, dependent: :nullify

  validates :po_number, :po_date, :supplier_name, :sku_id, :item_name, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :purchase_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :delivered_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[Open Closed Completed] }

  validate :delivered_quantity_cannot_exceed_quantity

  def self.ransackable_attributes(auth_object = nil)
    %w[po_number supplier_name sku_id item_name status]
  end

  def self.ransackable_associations(auth_object = nil)
    ["raw_material_inwards"]
  end

  def remaining_quantity
    [quantity - delivered_quantity, 0].max
  end

  def closed?
    status == 'Closed' || status == 'Completed'
  end

  def open?
    status == 'Open'
  end

  private

  def delivered_quantity_cannot_exceed_quantity
    if delivered_quantity.present? && quantity.present? && delivered_quantity > quantity
      errors.add(:delivered_quantity, "cannot exceed the ordered quantity")
    end
  end
end
