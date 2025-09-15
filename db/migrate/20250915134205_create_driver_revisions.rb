class CreateDriverRevisions < ActiveRecord::Migration[7.2]
  def change
    create_table :driver_revisions do |t|
      t.string :name
      t.integer :org_id

      t.timestamps
    end
  end
end
