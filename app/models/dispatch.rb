class Dispatch < ApplicationRecord
  belongs_to :location, optional: true
  before_create :generate_d_id
  has_many :dispatch_items, dependent: :destroy

  accepts_nested_attributes_for :dispatch_items, allow_destroy: true

  ransacker :d_id_str do
    Arel.sql("CAST(d_id AS TEXT)")
  end

  ransacker :search_all do
    Arel.sql(
      "CAST(d_id AS TEXT) || ' ' || COALESCE(courier_company, '') || ' ' || COALESCE(mode_of_shipment, '')"
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[d_id_str courier_company mode_of_shipment progress created_at updated_at search_all]
  end

  def self.ransackable_ransackers(auth_object = nil)
    {
      d_id_str: ransacker(:d_id_str) { Arel.sql("CAST(d_id AS TEXT)") },
      search_all: ransacker(:search_all) {
        Arel.sql(
          "CAST(d_id AS TEXT) || ' ' || COALESCE(courier_company, '') || ' ' || COALESCE(mode_of_shipment, '')"
        )
      }
    }
  end

  def self.ransackable_associations(auth_object = nil)
    %w[dispatch_items location]
  end

  private

  def generate_d_id
    last_d_id = Dispatch.order(:created_at).last&.d_id
    number = last_d_id.present? ? last_d_id.gsub(/\D/, '').to_i + 1 : 1
    self.d_id = "D#{number.to_s.rjust(6, '0')}"
  end
end
