class CreateInputs < ActiveRecord::Migration[7.2]
  def change
    create_table :inputs do |t|
      t.string :invoice_no
      t.date :invoice_date
      t.references :shipper_name, null: true, foreign_key: { to_table: :clients }
      t.references :consignee_name, null: true, foreign_key: { to_table: :clients }
      t.references :importer_name, null: true, foreign_key: { to_table: :clients }
      t.string :order_no_from_dispatch
      t.string :currency
      t.string :fedex_awb_no
      t.integer :marks_no_id
      t.integer :no_of_packages
      t.integer :type_of_packages_id
      t.integer :complete_description_of_goods_id
      t.integer :hsn_id
      t.decimal :qty_pcs, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.integer :org_id
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
  end
end
