class CreateDispatches < ActiveRecord::Migration[7.2]
  def change
    create_table :dispatches do |t|
      t.references :location, foreign_key: true
      t.date :dispatch_date
      t.date :delivery_date
      t.string :courier_company
      t.string :mode_of_shipment
      t.string :d_id
      t.string :track_no
      t.string :progress
      
      t.timestamps
    end
  end
end
