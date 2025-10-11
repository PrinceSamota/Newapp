class AddClientTypesToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :client_types, :text
  end
end
