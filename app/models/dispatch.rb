class Dispatch < ApplicationRecord
    belongs_to :client, optional: true
end
