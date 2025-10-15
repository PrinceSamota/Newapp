class RemoveFieldsFromInputs < ActiveRecord::Migration[7.2]
  def change
        remove_column :inputs, :marks_no_id, :integer
        remove_column :inputs, :no_of_packages, :integer
        remove_column :inputs, :type_of_packages_id, :integer
        remove_column :inputs, :complete_description_of_goods_id, :integer
        remove_column :inputs, :hsn_id, :integer
        remove_column :inputs, :qty_pcs, :decimal
        remove_column :inputs, :price, :decimal
  end
end
