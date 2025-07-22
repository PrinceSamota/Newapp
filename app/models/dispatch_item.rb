class DispatchItem < ApplicationRecord
    belongs_to :dispatch
  
    validates :order_no, :quantity, :courier_company, :mode_of_shipment, presence: true
  end