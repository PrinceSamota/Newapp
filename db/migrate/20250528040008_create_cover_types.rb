class CreateCoverTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :cover_types do |t|
      t.string :name
      t.integer :org_id

      t.timestamps
    end
  end
end
