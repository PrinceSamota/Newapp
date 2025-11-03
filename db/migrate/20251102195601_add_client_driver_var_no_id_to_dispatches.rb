class AddClientDriverVarNoIdToDispatches < ActiveRecord::Migration[7.2]
  def change
    add_column :dispatches, :client_driver_var_no_id, :integer
  end
end
