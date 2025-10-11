class AddAdvanceAuthorizationToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :advance_authorization_lic_no_and_date, :string
    add_column :clients, :advance_authorization_file_no, :string
  end
end
