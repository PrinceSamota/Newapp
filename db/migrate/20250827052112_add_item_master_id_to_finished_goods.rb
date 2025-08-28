class AddItemMasterIdToFinishedGoods < ActiveRecord::Migration[7.2]
  def change
    add_column :finished_goods, :item_master_id, :integer
  end
end
