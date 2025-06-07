class Order < ApplicationRecord
    has_many :items, dependent: :destroy
    has_many :order_details, dependent: :destroy
end
