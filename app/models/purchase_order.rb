class PurchaseOrder < ApplicationRecord
  has_many :raw_material_stock_batches, dependent: :nullify
  has_many :purchase_order_items, dependent: :destroy
  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true

  validates :po_number, :po_date, :supplier_name, presence: true
  validates :po_number, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[Open Closed Completed] }

  def self.ransackable_attributes(auth_object = nil)
    %w[po_number supplier_name status]
  end

  def self.ransackable_associations(auth_object = nil)
    ["raw_material_stock_batches", "purchase_order_items"]
  end

  def closed?
    status == 'Closed' || status == 'Completed'
  end

  def open?
    status == 'Open'
  end

  def update_status_based_on_items!
    return if purchase_order_items.empty?
    
    if purchase_order_items.all? { |item| item.remaining_quantity <= 0 }
      update(status: 'Completed')
    elsif status == 'Completed'
      update(status: 'Open')
    end
  end
end
