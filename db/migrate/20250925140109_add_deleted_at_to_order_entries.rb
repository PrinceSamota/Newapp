class AddDeletedAtToOrderEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :order_entries, :deleted_at, :datetime
    add_index :order_entries, :deleted_at
  end
end
