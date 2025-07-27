class AddBomTagToBillOfMaterials < ActiveRecord::Migration[7.2]
  def change
    add_column :bill_of_materials, :bom_tag, :string
  end
end
