class DispatchItem < ApplicationRecord
    belongs_to :dispatch
    belongs_to :order_entry
    validates :order_entry_id, presence: true
    def self.ransackable_attributes(auth_object = nil)
      %w[id order_no d_id quantity created_at updated_at]
    end
  
    def self.ransackable_associations(auth_object = nil)
      %w[dispatch]
    end
  end