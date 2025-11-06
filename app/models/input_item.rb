class InputItem < ApplicationRecord
  belongs_to :input, inverse_of: :input_items
  belongs_to :description_of_good, class_name: 'DescriptionOfGood', foreign_key: 'description_of_goods_id'

  validates :no_of_boxes, :qty_per_box, :net_weight, :gross_weight,
            :length, :width, :height, :order_no, presence: true
end
