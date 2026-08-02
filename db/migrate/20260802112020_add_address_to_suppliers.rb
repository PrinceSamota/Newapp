class AddAddressToSuppliers < ActiveRecord::Migration[7.2]
  def change
    add_column :suppliers, :address, :text
  end
end
