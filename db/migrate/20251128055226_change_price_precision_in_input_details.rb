class ChangePricePrecisionInInputDetails < ActiveRecord::Migration[7.2]
  def change
    change_column :input_details, :price, :decimal, precision: 10, scale: 4
  end
end
