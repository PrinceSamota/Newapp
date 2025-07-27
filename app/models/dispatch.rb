class Dispatch < ApplicationRecord
    belongs_to :location, optional: true
    before_create :generate_d_id
    has_many :dispatch_items, dependent: :destroy

  accepts_nested_attributes_for :dispatch_items, allow_destroy: true

  
 
  private

  def generate_d_id
    last_d_id = Dispatch.order(:created_at).last&.d_id

    if last_d_id.present?
      number = last_d_id.gsub(/\D/, '').to_i + 1
    else
      number = 1
    end

    self.d_id = "D#{number.to_s.rjust(6, '0')}"
  end
end
