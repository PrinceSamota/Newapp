class InputItem < ApplicationRecord
  belongs_to :input
  belongs_to :description_of_good, class_name: 'DescriptionOfGood', foreign_key: 'description_of_goods_id'
  validates :no_of_boxes, presence: true
  validates :qty_per_box, presence: true
  validates :net_weight, presence: true
  validates :gross_weight, presence: true
  validates :length, presence: true
  validates :width, presence: true
  validates :height, presence: true
  validates :order_no, presence: true
end
