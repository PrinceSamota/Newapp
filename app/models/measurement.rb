class Measurement < ApplicationRecord
    belongs_to :organization, foreign_key: :org_id, optional: true
    has_many :item_masters
    validates :name, presence: true
  end
  