class AddExecutedToProductionOrder < ActiveRecord::Migration[7.2]
  def change
    add_column :production_orders, :executed, :boolean, default: false
  end
end
