class AddColorToDispatches < ActiveRecord::Migration[7.2]
  def change
    add_column :dispatches, :color, :string
  end
end
