class AddPoInvoiceAndStockUpdatedToRawMaterialStockItems < ActiveRecord::Migration[7.2]
  def change
    add_column :raw_material_stock_items, :po_invoice, :string
    add_column :raw_material_stock_items, :stock_updated, :boolean, default: false

    # Backfill existing items so we don't accidentally double-count them
    reversible do |dir|
      dir.up do
        RawMaterialStockItem.update_all(stock_updated: true)
      end
    end
  end
end
