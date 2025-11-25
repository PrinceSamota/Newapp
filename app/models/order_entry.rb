class OrderEntry < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :client
  belongs_to :item_master, optional: true
  belongs_to :location, optional: true
  belongs_to :driver_revision, optional: true
  attr_accessor :generate_serial
  before_create :generate_serial_numbers
  has_many :dispatch_items, foreign_key: :order_no, primary_key: :order_no
  def dispatch_d_id
    dispatch_item = DispatchItem.find_by(order_no: self.order_no)
    dispatch_item&.dispatch&.d_id
  end
  def self.ransackable_attributes(auth_object = nil)
    %w[order_no article_no sku_number created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[client]
  end
  private

  def generate_sno_changed_to_true?
    generate_sno_changed? && ActiveModel::Type::Boolean.new.cast(generate_sno)
  end

  def generate_serial_numbers
    if self.generate_sno
      # Find the maximum end_serial_no
      last_end_serial = OrderEntry.pluck(:end_serial_no).compact.map{|x| x.gsub(/\D/, "")}.map(&:to_i).max || 0
  
      new_start_number = last_end_serial + 1
      self.start_serial_no = new_start_number.to_s
  
      if self.qty.present? && self.qty.to_i > 0
        new_end_number = new_start_number + self.qty.to_i - 1
        self.end_serial_no = new_end_number.to_s
      end
    end
  end  

  def self.ransackable_attributes(auth_object = nil)
    %w[
      order_no
      article_no
      sku_number
    ]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[client dispatch_items]
  end
  validates :order_no, presence: { message: "Order Number is required" }
  validates :article_no, presence: { message: "Article Number is required" }
  validates :target_date, presence: { message: "Target Date is required" }
  validates :qty, presence: { message: "Quantity is required" }
  validates :fuse_type, presence: { message: "Fuse Type is required" }
  validates :loop, presence: { message: "Loop is required" }
  validates :item_type, presence: { message: "Item Type is required" }
  validates :profile, presence: { message: "Profile is required" }
  validates :wattage, presence: { message: "Wattage is required" }
  validates :voltage, presence: { message: "Voltage is required" }
  validates :length, presence: { message: "Length is required" }
  validates :cct, presence: { message: "CCT is required" }
  validates :cover_type, presence: { message: "Cover Type is required" }
end
