class DescriptionOfGood < ApplicationRecord
    validates :name, presence: true
    has_many :input_items, dependent: :nullify
  end
  