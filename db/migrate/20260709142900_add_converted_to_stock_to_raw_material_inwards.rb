class AddConvertedToStockToRawMaterialInwards < ActiveRecord::Migration[7.2]
  def change
    add_column :raw_material_inwards, :converted_to_stock, :boolean
  end
end
