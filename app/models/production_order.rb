require "csv"

class ProductionOrder < ApplicationRecord
    has_many :production_order_items, inverse_of: :production_order, dependent: :destroy
    accepts_nested_attributes_for :production_order_items, allow_destroy: true
    belongs_to :item_master, optional: true
    before_create :generate_pid

    has_paper_trail save_changes: true
    def self.ransackable_attributes(auth_object = nil)
        %w[created_at id item_master_id pid updated_at]
      end
    
      def self.ransackable_associations(auth_object = nil)
        %w[production_order_items]
      end

      def self.to_csv
        attributes = [
          "PID",
          "BOM Number",
          "SKU",
          "Current Stock",
          "Finished Good",
          "Executed"
        ]
    
        CSV.generate(headers: true) do |csv|
          csv << attributes
    
          all.includes(:production_order_items).each do |order|
            order.production_order_items.each do |item|
    
              item_master = ItemMaster.find_by(id: item.item_master_id)
              bom_number, finished_good = item.bom.to_s.split(",", 2)
    
              csv << [
                order.pid,
                bom_number,
                item.sku_id,
                item_master&.opening_stock,
                item_master&.item_name,
                order.executed ? "Yes" : "No"
              ]
            end
          end
        end
      end

    private
  
    def generate_pid
        last_pid_number = ProductionOrder.order(:created_at).last&.pid&.gsub("PID", "")&.to_i || 0
        new_number = last_pid_number + 1
        self.pid = "PID" + new_number.to_s.rjust(4, '0')  # PID0001 format
      end
  end