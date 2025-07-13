class Profile < ApplicationRecord
    has_many :item_masters
validates :name, presence: true, uniqueness: true
end
