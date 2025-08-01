class Client < ApplicationRecord
    validates :name, presence: true, uniqueness: { scope: :org_id }
    has_many :order_entries
    def self.ransackable_attributes(auth_object = nil)
      %w[name email] # or whatever fields you want to search
    end
  end
  