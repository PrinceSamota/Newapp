class CreateDispatchItems < ActiveRecord::Migration[7.2]
  def change
    create_table :dispatch_items do |t|
      t.references :dispatch, null: false, foreign_key: true
      t.string :order_no
      t.integer :quantity
      t.string :courier_company
      t.string :mode_of_shipment

      t.timestamps
    end
  end
end
