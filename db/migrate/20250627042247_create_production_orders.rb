class CreateProductionOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :production_orders do |t|
      t.string :pid
      t.integer :item_master_id
      
      t.timestamps
    end
  end
end
