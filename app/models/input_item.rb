class InputItem < ApplicationRecord
  belongs_to :input
  belongs_to :description_of_good, class_name: 'DescriptionOfGood', foreign_key: 'description_of_goods_id'
end
