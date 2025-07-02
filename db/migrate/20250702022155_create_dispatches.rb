class CreateDispatches < ActiveRecord::Migration[7.2]
  def change
    create_table :dispatches do |t|
      t.string :order_no
      t.integer :quantity
      t.string :client
      t.string :mode_of_shipment
      t.date :dispatch_date
      t.date :delivery_date
      t.string :courier_company

      t.timestamps
    end
  end
end
