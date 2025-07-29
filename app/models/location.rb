class Location < ApplicationRecord
    has_many :dispatch
    has_many :order_entry
end
