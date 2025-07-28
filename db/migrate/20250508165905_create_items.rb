class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.string :article_no
      t.integer :order_id

      t.timestamps
    end
  end
end
