class RawMaterialInward < ApplicationRecord
  belongs_to :purchase_order, optional: true
end
