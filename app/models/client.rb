class Client < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :org_id }
  has_many :order_entries
  
  # File attachments
  has_one_attached :logo
  has_one_attached :qr_code
  has_one_attached :signature
  
  def self.ransackable_attributes(auth_object = nil)
    %w[name email company_name contact_no gst_no]
  end

  # Available types
  AVAILABLE_TYPES = %w[shipper manufacturer consignee buyer distributor].freeze
  
  # Serialize client_types as array (Rails 7 syntax)
  serialize :client_types, type: Array, coder: JSON
  
  def has_type?(type)
    (client_types || []).include?(type)
  end
  
  def add_type(type)
    return unless AVAILABLE_TYPES.include?(type)
    self.client_types = ((client_types || []) + [type]).uniq
    save
  end
  
  def remove_type(type)
    self.client_types = (client_types || []) - [type]
    save
  end
end
