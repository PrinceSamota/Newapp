class AddFieldsToDispatches < ActiveRecord::Migration[7.2]
  def change
    add_column :dispatches, :client_driver_ver_no, :string
    add_column :dispatches, :mfg_date, :date
    add_column :dispatches, :order_receiving_date, :date
  end
end
