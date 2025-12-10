class AddShortcodeToItemMasters < ActiveRecord::Migration[7.2]
  def change
    add_column :item_masters, :shortcode, :string
  end
end
