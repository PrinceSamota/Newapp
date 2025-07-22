class Status < ApplicationRecord
    has_many :order_entries
end
