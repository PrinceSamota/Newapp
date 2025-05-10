class CreateAvailabilities < ActiveRecord::Migration[7.2]
  def change
    create_table :availabilities do |t|
      t.string :category
      t.string :variable
      t.integer :value
      t.integer :user_id

      t.timestamps
    end
  end
end
