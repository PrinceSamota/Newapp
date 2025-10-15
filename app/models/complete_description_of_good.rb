class CompleteDescriptionOfGood < ApplicationRecord
  belongs_to :org, optional: true
  has_many :input_details
end
