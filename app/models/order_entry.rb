class OrderEntry < ApplicationRecord
    belongs_to :client
    belongs_to :status, optional: true

    before_create :generate_serial_numbers

    private
  
    def generate_serial_numbers
      # Get last used start_serial_no (e.g., "S000051")
      last_serial = OrderEntry.order(:created_at).last&.start_serial_no
      last_number = last_serial.to_s.gsub(/[^\d]/, '').to_i rescue 0
  
      # New start number
      new_start_number = last_number + 1
      self.start_serial_no = "S#{new_start_number.to_s.rjust(6, '0')}"
  
      # Generate end_serial_no using qty
      if self.qty.present? && self.qty > 0
        new_end_number = new_start_number + self.qty - 1
        self.end_serial_no = "S#{new_end_number.to_s.rjust(6, '0')}"
      end
    end
end
