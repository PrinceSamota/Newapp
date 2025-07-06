class Dispatch < ApplicationRecord
    before_create :generate_order_no
    belongs_to :client, optional: true
  private

  def generate_order_no
    last_order = Dispatch.order(:created_at).last
    if last_order&.order_no.present?
      number = last_order.order_no.gsub("ODR", "").to_i + 1
    else
      number = 1
    end
    self.order_no = "ODR#{number.to_s.rjust(5, '0')}"
  end
end
