class OrderEntry < ApplicationRecord
  belongs_to :client
  belongs_to :location, optional: true
  attr_accessor :generate_serial
  before_create :generate_serial_numbers
  has_many :dispatch_items, foreign_key: :order_no, primary_key: :order_no
  def dispatch_d_id
    dispatch_item = DispatchItem.find_by(order_no: self.order_no)
    dispatch_item&.dispatch&.d_id
  end
  private

  def generate_serial_numbers
    if generate_sno 
      # Get last order's end_serial_no (e.g., "S000045")
      last_end_serial = OrderEntry.order(:created_at).last&.end_serial_no
      last_number = last_end_serial.to_s.gsub(/[^\d]/, '').to_i rescue 0

      # Start from last end serial + 1
      new_start_number = last_number + 1
      self.start_serial_no = "S#{new_start_number.to_s.rjust(6, '0')}"

      # Generate end_serial_no using qty
      if self.qty.present? && self.qty > 0
        new_end_number = new_start_number + self.qty - 1
        self.end_serial_no = "S#{new_end_number.to_s.rjust(6, '0')}"
      end
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      order_no
      article_no
      dispatch_no
      sku_id
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w["client", "dispatch_items", "location"]
  end
end
