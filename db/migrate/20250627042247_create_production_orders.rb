class CreateProductionOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :production_orders do |t|
      t.string :pid

      t.timestamps
    end
  end
end
