class ProductionOrder < ApplicationRecord
    has_many :production_order_items, inverse_of: :production_order, dependent: :destroy
    accepts_nested_attributes_for :production_order_items, allow_destroy: true
  
    before_create :generate_pid

    has_paper_trail save_changes: true

    private
  
    def generate_pid
        last_pid_number = ProductionOrder.order(:created_at).last&.pid&.gsub("PID", "")&.to_i || 0
        new_number = last_pid_number + 1
        self.pid = "PID" + new_number.to_s.rjust(4, '0')  # PID0001 format
      end
  end