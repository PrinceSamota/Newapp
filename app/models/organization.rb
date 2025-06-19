class Organization < ApplicationRecord
    has_many :users, foreign_key: 'org_id'
end
