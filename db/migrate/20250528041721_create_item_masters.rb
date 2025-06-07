class CreateItemMasters < ActiveRecord::Migration[7.2]
  def change
    create_table :item_masters do |t|
      t.string :item_name
      t.string :unit_of_measurement
      t.string :item_category
      t.integer :opening_stock
      t.integer :purchase_price
      t.integer :sale_price
      t.integer :minimum_stock_level
      t.boolean :is_bOM
      t.string :article_no
      t.string :loop_color
      t.string :client
      t.boolean :status
      t.string :profile
      t.string :start_serial_no
      t.string :end_serial_no
      t.string :invoice_no
      t.string :fuse
      t.string :sku_id
      t.string :tracking_no
      t.string :current_status
      t.date :manufacturing_date
      t.date :dispatch_date
      t.date :delivery_date

      t.timestamps
    end
  end
end
