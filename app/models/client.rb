class Client < ApplicationRecord
    validates :name, presence: true, uniqueness: { scope: :org_id }
    has_many :dispatches
    has_many :order_entries
  end
  