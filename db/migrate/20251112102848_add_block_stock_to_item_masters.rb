class AddBlockStockToItemMasters < ActiveRecord::Migration[7.2]
  def change
    add_column :item_masters, :block_stock, :integer
  end
end
