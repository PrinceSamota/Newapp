class InputDetail < ApplicationRecord
  belongs_to :input, inverse_of: :input_details
  belongs_to :marks_no, optional: true
  belongs_to :type_of_package, optional: true
  belongs_to :complete_description_of_good, optional: true
  belongs_to :hsn, optional: true

  validates :marks_no_id, :no_of_packages, :type_of_package_id,
            :complete_description_of_good_id, :hsn_id, :qty_pcs, :price, presence: true
end
