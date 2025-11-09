class AddOrderReceivingDateToOrderEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :order_entries, :order_receiving_date, :date
  end
end
