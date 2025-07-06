class Client < ApplicationRecord
    validates :name, presence: true, uniqueness: { scope: :org_id }
    has_many :dispatches
  end
  