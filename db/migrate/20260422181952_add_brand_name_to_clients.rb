class AddBrandNameToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :brand_name, :string
  end
end
