class AddOrderNoToInputDetails < ActiveRecord::Migration[7.2]
  def change
    add_column :input_details, :order_no, :string
  end
end
