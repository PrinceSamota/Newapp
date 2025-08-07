class AddOrderEntryIdToDispatchItems < ActiveRecord::Migration[7.2]
  def change
    add_column :dispatch_items, :order_entry_id, :integer
  end
end
