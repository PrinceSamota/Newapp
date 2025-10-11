class CreateCompleteDescriptionOfGoods < ActiveRecord::Migration[7.2]
  def change
    create_table :complete_description_of_goods do |t|
      t.string :name
      t.integer :org_id

      t.timestamps
    end
  end
end
