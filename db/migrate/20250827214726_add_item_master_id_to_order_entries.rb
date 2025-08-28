class AddItemMasterIdToOrderEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :order_entries, :item_master_id, :integer
  end
end
