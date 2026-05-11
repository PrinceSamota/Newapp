class Input < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shipper_name, class_name: 'Client', optional: true
  belongs_to :consignee_name, class_name: 'Client', optional: true
  belongs_to :importer_name, class_name: 'Client', optional: true
  belongs_to :currency, optional: true
  belongs_to :dispatch, optional: true

  has_many :input_items, dependent: :destroy, inverse_of: :input
  has_many :input_details, dependent: :destroy, inverse_of: :input

  accepts_nested_attributes_for :input_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :input_details, allow_destroy: true, reject_if: :all_blank

  validates_associated :input_items
  validates_associated :input_details

  validates :invoice_no, :invoice_date, :shipper_name_id, 
            :consignee_name_id, :order_no_from_dispatch, presence: true
end
