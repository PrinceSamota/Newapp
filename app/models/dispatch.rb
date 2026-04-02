require 'csv'
class Dispatch < ApplicationRecord
  belongs_to :location, optional: true

  before_create :generate_d_id
  has_many :dispatch_items, dependent: :destroy
  belongs_to :client_driver_var_no, optional: true
  has_many :inputs

  accepts_nested_attributes_for :dispatch_items, allow_destroy: true

  validates :dispatch_items, presence: { message: "At least one order must be present in dispatch" }


  ransacker :d_id_str do
    Arel.sql("CAST(d_id AS TEXT)")
  end

  ransacker :search_all do |_parent|
    query = <<-SQL
      CAST(dispatches.d_id AS TEXT) || ' ' ||
      COALESCE(dispatches.courier_company, '') || ' ' ||
      COALESCE(dispatches.mode_of_shipment, '') || ' ' ||
      COALESCE((
        SELECT STRING_AGG(order_entries.order_no, ' ')
        FROM dispatch_items
        JOIN order_entries ON order_entries.id = dispatch_items.order_entry_id
        WHERE dispatch_items.dispatch_id = dispatches.id
      ), '') || ' ' ||
      COALESCE((
        SELECT STRING_AGG(order_entries.start_serial_no::text || '-' || order_entries.end_serial_no::text, ' ')
        FROM dispatch_items
        JOIN order_entries ON order_entries.id = dispatch_items.order_entry_id
        WHERE dispatch_items.dispatch_id = dispatches.id
      ), '')
    SQL
  
    Arel.sql(query)
  end

  scope :with_serial_in_range, ->(serial) {
    return none if serial.blank?
    
    joins(:dispatch_items).joins('JOIN order_entries ON order_entries.id = dispatch_items.order_entry_id')
      .where("
        order_entries.start_serial_no IS NOT NULL AND 
        order_entries.end_serial_no IS NOT NULL AND
        (
          (order_entries.start_serial_no ~ '^[0-9]+$' AND 
           order_entries.end_serial_no ~ '^[0-9]+$' AND
           ? BETWEEN CAST(order_entries.start_serial_no AS INTEGER) AND CAST(order_entries.end_serial_no AS INTEGER))
          OR
          (order_entries.start_serial_no = ? OR order_entries.end_serial_no = ?)
          OR
          (order_entries.start_serial_no ~ '^S[0-9]+$' AND 
           order_entries.end_serial_no ~ '^S[0-9]+$' AND
           ? ~ '^S[0-9]+$' AND
           ? BETWEEN CAST(SUBSTRING(order_entries.start_serial_no FROM 2) AS INTEGER) AND CAST(SUBSTRING(order_entries.end_serial_no FROM 2) AS INTEGER))
        )
      ", serial.to_i, serial, serial, serial, serial.gsub(/\D/, '').to_i)
      .distinct
  }

  def self.ransackable_attributes(auth_object = nil)
    %w[d_id_str courier_company mode_of_shipment progress created_at updated_at search_all]
  end

  def self.ransackable_ransackers(auth_object = nil)
    {
      d_id_str: ransacker(:d_id_str) { Arel.sql("CAST(d_id AS TEXT)") },
      search_all: ransacker(:search_all) {
        Arel.sql(
          "CAST(d_id AS TEXT) || ' ' || " \
          "COALESCE(courier_company, '') || ' ' || " \
          "COALESCE(mode_of_shipment, '') || ' ' || " \
          "COALESCE(tracking_no, '') || ' ' || " \
          "COALESCE(invoice_no, '') || ' ' || " \
          "COALESCE((" \
            "SELECT STRING_AGG(dispatch_items.order_no, ' ') " \
            "FROM dispatch_items " \
            "WHERE dispatch_items.dispatch_id = dispatches.id" \
          "), '')"
        )
      }
    }
  end

  def self.ransackable_associations(auth_object = nil)
    %w[dispatch_items location]
  end

  def self.to_csv(records = all)
    headers = [
      "DID", "Dispatch Date", "Delivery Date", "Courier Company",
      "Mode of Shipment", "Tracking No", "Invoice No", "Progress", "Order Nos"
    ]

    CSV.generate(headers: true) do |csv|
      csv << headers

      records.each do |dispatch|
        csv << [
          dispatch.d_id,
          dispatch.dispatch_date,
          dispatch.delivery_date,
          dispatch.courier_company,
          dispatch.mode_of_shipment,
          dispatch.track_no,
          dispatch.invoice_no,
          dispatch.progress,
          dispatch.dispatch_items.map { |i| i.order_entry&.order_no }.compact.join(", ")
        ]
      end
    end
  end

  private

  def generate_d_id
    last_d_id = Dispatch.order(:created_at).last&.d_id
    number = last_d_id.present? ? last_d_id.gsub(/\D/, '').to_i + 1 : 1
    self.d_id = "D#{number.to_s.rjust(6, '0')}"
  end
end
