class Input < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :marks_no, optional: true
  belongs_to :type_of_packages, class_name: 'TypeOfPackage', optional: true
  belongs_to :complete_description_of_goods, class_name: 'CompleteDescriptionOfGood', optional: true
  belongs_to :hsn, optional: true
  belongs_to :shipper_name, class_name: 'Client', optional: true
  belongs_to :consignee_name, class_name: 'Client', optional: true
  belongs_to :importer_name, class_name: 'Client', optional: true
  has_many :input_items, dependent: :destroy
  accepts_nested_attributes_for :input_items, allow_destroy: true
  
  validates :invoice_no, presence: true
  validates :invoice_date, presence: true

  delegate :name, to: :marks_no, prefix: true, allow_nil: true
  delegate :name, to: :type_of_packages, prefix: true, allow_nil: true
  delegate :name, to: :complete_description_of_goods, prefix: true, allow_nil: true
  delegate :name, to: :hsn, prefix: true, allow_nil: true

  def self.ransackable_attributes(auth_object = nil)
    %w[invoice_no invoice_date shipper_name consignee_name importer_name order_no_from_dispatch currency fedex_awb_no no_of_packages qty_pcb price]
  end
end
