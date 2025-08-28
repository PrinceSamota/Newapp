class RemoveItemMasterIdFromOrderEntries < ActiveRecord::Migration[7.2]
  def change
    remove_column :order_entries, :item_master_id, :integer
  end
end
