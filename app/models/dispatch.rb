class Dispatch < ApplicationRecord
    belongs_to :client, optional: true
    has_many :dispatch_items, dependent: :destroy

  accepts_nested_attributes_for :dispatch_items, allow_destroy: true

  validates :client_id, :dispatch_date, :delivery_date, presence: true
end
