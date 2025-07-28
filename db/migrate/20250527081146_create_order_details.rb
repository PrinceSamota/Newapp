class CreateOrderDetails < ActiveRecord::Migration[7.2]
  def change
    create_table :order_details do |t|
      t.integer :order_id
      t.string :sheet_name
      t.string :article_no
      t.string :service
      t.string :fixture_type
      t.string :suspension
      t.string :voltage
      t.string :length
      t.string :kelvin
      t.string :cover
      t.string :watt
      t.string :stripe_set
      t.string :profile
      t.string :output_count
      t.string :output_voltage
      t.string :outputs_count
      t.string :wiring_map
      t.string :loop_color
      t.string :client
      t.string :status
      t.string :profile2
      t.string :start_serial_no
      t.string :end_serial_no
      t.string :invoice_no
      t.string :fuse
      t.string :sku_no

      t.timestamps
    end
  end
end
