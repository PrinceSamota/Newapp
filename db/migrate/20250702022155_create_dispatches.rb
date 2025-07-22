class CreateDispatches < ActiveRecord::Migration[7.2]
  def change
    create_table :dispatches do |t|
      t.string :client
      t.date :dispatch_date
      t.date :delivery_date
  

      t.timestamps
    end
  end
end
