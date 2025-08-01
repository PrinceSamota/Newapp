# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_07_27_101938) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "availabilities", force: :cascade do |t|
    t.string "category"
    t.string "variable"
    t.integer "value"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bill_of_materials", force: :cascade do |t|
    t.string "name"
    t.string "bom_number"
    t.boolean "flag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bom_tag"
  end

  create_table "bom_raw_material_items", force: :cascade do |t|
    t.integer "bill_of_material_id"
    t.string "item_name"
    t.float "quantity"
    t.string "sku_id"
    t.string "unit"
    t.integer "item_master_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bom_raw_materials", force: :cascade do |t|
    t.integer "bom_id"
    t.string "item_master_id"
    t.float "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "boms", force: :cascade do |t|
    t.string "bom_number"
    t.integer "item_master_id"
    t.string "sku_id"
    t.integer "quantity"
    t.string "unit"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "ccts", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cover_types", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dispatch_items", force: :cascade do |t|
    t.bigint "dispatch_id", null: false
    t.string "order_no"
    t.float "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dispatch_id"], name: "index_dispatch_items_on_dispatch_id"
  end

  create_table "dispatches", force: :cascade do |t|
    t.integer "location_id"
    t.date "dispatch_date"
    t.date "delivery_date"
    t.string "courier_company"
    t.string "mode_of_shipment"
    t.string "d_id"
    t.string "track_no"
    t.string "progress"
    t.string "invoice_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "client_id"
  end

  create_table "extras", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "finished_goods", force: :cascade do |t|
    t.integer "bill_of_material_id"
    t.string "item_name"
    t.float "quantity"
    t.string "sku_id"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fuse_types", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_masters", force: :cascade do |t|
    t.string "item_name"
    t.integer "opening_stock"
    t.decimal "purchase_price"
    t.decimal "sale_price"
    t.boolean "is_bom"
    t.string "sku_id"
    t.string "article_number"
    t.integer "minimum_stock_level"
    t.integer "category_id"
    t.integer "measurement_id"
    t.integer "fuse_type_id"
    t.integer "loop_id"
    t.integer "item_type_id"
    t.integer "profile_id"
    t.integer "wattage_id"
    t.integer "voltage_id"
    t.integer "length_id"
    t.integer "cct_id"
    t.integer "cover_type_id"
    t.integer "extra_id"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_types", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "article_no"
    t.integer "order_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "loop_color"
    t.string "fuse"
    t.string "profile"
    t.string "status"
    t.string "start_serial_no"
    t.string "end_serial_no"
    t.string "invoice_no"
    t.string "client"
    t.string "tracking_no"
    t.string "sku_no"
  end

  create_table "lengths", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "loops", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "measurements", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_details", force: :cascade do |t|
    t.integer "order_id"
    t.string "sheet_name"
    t.string "article_no"
    t.string "service"
    t.string "fixture_type"
    t.string "suspension"
    t.string "voltage"
    t.string "length"
    t.string "kelvin"
    t.string "cover"
    t.string "watt"
    t.string "stripe_set"
    t.string "profile"
    t.string "output_count"
    t.string "output_voltage"
    t.string "outputs_count"
    t.string "wiring_map"
    t.string "loop_color"
    t.string "client"
    t.string "status"
    t.string "profile2"
    t.string "start_serial_no"
    t.string "end_serial_no"
    t.string "invoice_no"
    t.string "fuse"
    t.string "sku_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_entries", force: :cascade do |t|
    t.string "order_no"
    t.string "article_no"
    t.string "client_id"
    t.date "target_date"
    t.integer "location_id"
    t.integer "qty"
    t.string "sku_number"
    t.string "fuse_type"
    t.string "loop"
    t.string "item_type"
    t.string "profile"
    t.string "wattage"
    t.string "voltage"
    t.string "length"
    t.string "cct"
    t.string "cover_type"
    t.string "start_serial_no"
    t.string "end_serial_no"
    t.string "mfg_date"
    t.string "driver_revision_no"
    t.string "invoice_no"
    t.string "tracking_no"
    t.string "dispatch_no"
    t.string "status"
    t.string "remark"
    t.string "box"
    t.string "extra"
    t.boolean "generate_sno"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "orders", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sheet_name"
    t.string "article_no"
    t.string "service"
    t.string "types"
    t.string "suspension"
    t.string "voltage"
    t.string "length"
    t.string "kelvin"
    t.string "cover"
    t.string "watt"
    t.string "stripe_set"
    t.string "profile"
    t.string "output_count"
    t.string "output_voltage"
    t.string "outputs_count"
    t.string "wiring_map"
    t.string "loop_color"
    t.string "client"
    t.string "status"
    t.string "profile2"
    t.string "start_serial_no"
    t.string "end_serial_no"
    t.string "invoice_no"
    t.string "fuse"
    t.string "sku_no"
  end

  create_table "organizations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "production_order_items", force: :cascade do |t|
    t.integer "production_order_id"
    t.text "bom_ids"
    t.string "sku_id"
    t.string "item_name"
    t.integer "current_stock"
    t.float "quantity"
    t.string "bom"
    t.string "stage"
    t.integer "item_master_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "production_orders", force: :cascade do |t|
    t.string "pid"
    t.integer "item_master_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_material_inwards", force: :cascade do |t|
    t.string "supplier_name"
    t.date "receiving_date"
    t.string "sku_id"
    t.string "item_name"
    t.integer "receiving_quantity"
    t.float "purchase_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_material_stock_batches", force: :cascade do |t|
    t.integer "supplier_id"
    t.date "receiving_date"
    t.string "supplier_invoice_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "raw_material_stock_items", force: :cascade do |t|
    t.integer "raw_material_stock_batch_id"
    t.string "item_name"
    t.string "sku_id"
    t.integer "receiving_quantity"
    t.decimal "purchase_price"
    t.integer "item_master_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.integer "org_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.string "source_type"
    t.bigint "source_id"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["source_type", "source_id"], name: "index_versions_on_source_type_and_source_id"
  end

  create_table "voltages", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wattages", force: :cascade do |t|
    t.string "name"
    t.integer "org_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "dispatch_items", "dispatches"
  add_foreign_key "users", "organizations", column: "org_id"
end
