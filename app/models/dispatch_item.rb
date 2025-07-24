class DispatchItem < ApplicationRecord
    belongs_to :dispatch
    belongs_to :order, foreign_key: :order_no, primary_key: :order_no, optional: true
    validates :order_no, :quantity,  presence: true
  end