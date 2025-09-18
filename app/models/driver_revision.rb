class DriverRevision < ApplicationRecord
    has_many :order_entries
    validates :name, presence: true, uniqueness: true
end
