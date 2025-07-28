class CreateBillOfMaterials < ActiveRecord::Migration[7.2]
  def change
    create_table :bill_of_materials do |t|
      t.string :name
      t.string :bom_number
      
      t.timestamps
    end
  end
end
