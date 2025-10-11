class CreateInputItems < ActiveRecord::Migration[7.2]
  def change
    create_table :input_items do |t|
      t.references :input, null: false, foreign_key: true
      t.integer :no_of_boxes
      t.integer :description_of_goods_id
      t.decimal :qty_per_box, precision: 10, scale: 2
      t.decimal :net_weight, precision: 10, scale: 2
      t.decimal :gross_weight, precision: 10, scale: 2
      t.decimal :length, precision: 10, scale: 2
      t.decimal :width, precision: 10, scale: 2
      t.decimal :height, precision: 10, scale: 2
      t.string :order_no

      t.timestamps
    end
  end
end