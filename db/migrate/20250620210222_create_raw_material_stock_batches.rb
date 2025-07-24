class CreateRawMaterialStockBatches < ActiveRecord::Migration[7.2]
  def change
    create_table :raw_material_stock_batches do |t|
      t.references :supplier, foreign_key: true
      t.date :receiving_date
      t.string :supplier_invoice_number

      t.timestamps
    end
  end
end
