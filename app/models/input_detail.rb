class InputDetail < ApplicationRecord
  belongs_to :input
  belongs_to :marks_no, optional: true
  belongs_to :type_of_package, optional: true
  belongs_to :complete_description_of_good, optional: true
  belongs_to :hsn, optional: true

  validates :marks_no_id, presence: true
  validates :no_of_packages, presence: true
  validates :type_of_package_id, presence: true
  validates :complete_description_of_good_id, presence: true
  validates :hsn_id, presence: true
  validates :qty_pcs, presence: true
  validates :price, presence: true
end

