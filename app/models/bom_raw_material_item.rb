class BomRawMaterialItem < ApplicationRecord
  belongs_to :bill_of_material
  belongs_to :item_master
end
