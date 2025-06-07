class AddDecodedFieldsToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :sheet_name, :string
    add_column :orders, :article_no, :string
    add_column :orders, :service, :string
    add_column :orders, :types, :string
    add_column :orders, :suspension, :string
    add_column :orders, :voltage, :string
    add_column :orders, :length, :string
    add_column :orders, :kelvin, :string
    add_column :orders, :cover, :string
    add_column :orders, :watt, :string
    add_column :orders, :stripe_set, :string
    add_column :orders, :profile, :string
    add_column :orders, :output_count, :string
    add_column :orders, :output_voltage, :string
    add_column :orders, :outputs_count, :string
    add_column :orders, :wiring_map, :string
    add_column :orders, :loop_color, :string
    add_column :orders, :client, :string
    add_column :orders, :status, :string
    add_column :orders, :profile2, :string
    add_column :orders, :start_serial_no, :string
    add_column :orders, :end_serial_no, :string
    add_column :orders, :invoice_no, :string
    add_column :orders, :fuse, :string
    add_column :orders, :sku_no, :string
  end
end
