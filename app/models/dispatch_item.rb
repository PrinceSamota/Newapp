class DispatchItem < ApplicationRecord
    belongs_to :dispatch
    belongs_to :order_entry, foreign_key: :order_no, primary_key: :order_no, optional: true
    validates :order_no, :quantity,  presence: true
    def self.ransackable_attributes(auth_object = nil)
      %w[id order_no d_id quantity created_at updated_at]
    end
  
    def self.ransackable_associations(auth_object = nil)
      %w[dispatch]
    end
  end