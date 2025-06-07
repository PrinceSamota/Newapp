class AddLoopFuseEtcToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :loop_color, :string
    add_column :items, :fuse, :string
    add_column :items, :profile, :string
    add_column :items, :status, :string
    add_column :items, :start_serial_no, :string
    add_column :items, :end_serial_no, :string
    add_column :items, :invoice_no, :string
    add_column :items, :client, :string
    add_column :items, :tracking_no, :string
    add_column :items, :sku_no, :string
  end
end
