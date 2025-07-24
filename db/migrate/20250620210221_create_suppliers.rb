class CreateSuppliers < ActiveRecord::Migration[7.2]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.integer :org_id

      t.timestamps
    end
  end
end
