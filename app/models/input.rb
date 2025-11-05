class Input < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shipper_name, class_name: 'Client', optional: true
  belongs_to :consignee_name, class_name: 'Client', optional: true
  belongs_to :importer_name, class_name: 'Client', optional: true
  belongs_to :currency, optional: true
  has_many :input_items, dependent: :destroy
  has_many :input_details, dependent: :destroy
  accepts_nested_attributes_for :input_items, allow_destroy: true
  accepts_nested_attributes_for :input_details, allow_destroy: true
  
  validates :invoice_no, presence: true
  validates :invoice_date, presence: true
  validates :shipper_name_id, presence: true
  validates :consignee_name_id, presence: true
  validates :order_no_from_dispatch, presence: true
end
