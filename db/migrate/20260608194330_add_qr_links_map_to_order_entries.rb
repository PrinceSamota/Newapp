class AddQrLinksMapToOrderEntries < ActiveRecord::Migration[7.2]
  def change
    add_column :order_entries, :qr_links_map, :json, default: {}
  end
end
