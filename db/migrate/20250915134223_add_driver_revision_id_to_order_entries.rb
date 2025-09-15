class AddDriverRevisionIdToOrderEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :order_entries, :driver_revision_id, :integer
  end
end
