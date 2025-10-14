class CreateInputDetails < ActiveRecord::Migration[7.2]
  def change
    create_table :input_details do |t|
      t.references :input, null: false, foreign_key: true
      t.integer :marks_no_id
      t.integer :no_of_packages
      t.integer :type_of_package_id
      t.integer :complete_description_of_good_id
      t.integer :hsn_id
      t.decimal :qty_pcs, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
