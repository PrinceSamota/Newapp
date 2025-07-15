# db/migrate/xxxxxx_create_versions.rb
class CreateVersions < ActiveRecord::Migration[7.2]
  TEXT_BYTES = 1_073_741_823

  def change
    create_table :versions do |t|
      t.string   :item_type, null: false
      t.bigint   :item_id,   null: false
      t.string   :event,     null: false
      t.string   :whodunnit
      t.text     :object, limit: TEXT_BYTES
      t.text     :object_changes, limit: TEXT_BYTES

      # Custom meta fields
      t.string   :source_type
      t.bigint   :source_id

      # Use fractional seconds for better precision (especially for MySQL)
      t.datetime :created_at, precision: 6
    end

    add_index :versions, %i[item_type item_id]
    add_index :versions, [:source_type, :source_id]
  end
end
