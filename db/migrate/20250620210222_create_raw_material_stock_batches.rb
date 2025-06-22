class CreateRawMaterialStockBatches < ActiveRecord::Migration[7.2]
  def change
    create_table :raw_material_stock_batches do |t|
      t.string :supplier_name
      t.date :receiving_date
      t.string :supplier_invoice_number

      t.timestamps
    end
  end
end
