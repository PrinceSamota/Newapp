class CreateClientDriverVarNos < ActiveRecord::Migration[7.2]
  def change
    create_table :client_driver_var_nos do |t|
      t.string :name

      t.timestamps
    end
  end
end
