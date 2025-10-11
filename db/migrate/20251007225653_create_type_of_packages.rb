class CreateTypeOfPackages < ActiveRecord::Migration[7.2]
  def change
    create_table :type_of_packages do |t|
      t.string :name
      t.integer :org_id

      t.timestamps
    end
  end
end
