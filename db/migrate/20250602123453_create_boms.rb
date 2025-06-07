class CreateBoms < ActiveRecord::Migration[7.2]
  def change
    create_table :boms do |t|
      t.string :bom_number
      t.references :item_master, null: false, foreign_key: true                      
      t.string :finished_good
      t.integer :quantity
      t.string :unit

      t.timestamps
    end
  end
end
