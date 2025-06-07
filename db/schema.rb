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

ActiveRecord::Schema[7.2].define(version: 2025_06_04_224758) do
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

  create_table "bom_raw_materials", force: :cascade do |t|
    t.integer "bom_id", null: false
    t.string "raw_material_sku"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bom_id"], name: "index_bom_raw_materials_on_bom_id"
  end

  create_table "boms", force: :cascade do |t|
    t.string "bom_number"
    t.integer "item_master_id", null: false
    t.string "finished_good"
    t.integer "quantity"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_master_id"], name: "index_boms_on_item_master_id"
  end

  create_table "item_masters", force: :cascade do |t|
    t.string "item_name"
    t.string "unit_of_measurement"
    t.string "item_category"
    t.integer "opening_stock"
    t.integer "purchase_price"
    t.integer "sale_price"
    t.integer "minimum_stock_level"
    t.boolean "is_bOM"
    t.string "article_no"
    t.string "loop_color"
    t.string "client"
    t.boolean "status"
    t.string "profile"
    t.string "start_serial_no"
    t.string "end_serial_no"
    t.string "invoice_no"
    t.string "fuse"
    t.string "sku_id"
    t.string "tracking_no"
    t.string "current_status"
    t.date "manufacturing_date"
    t.date "dispatch_date"
    t.date "delivery_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.string "article_no"
    t.integer "order_id", null: false
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
    t.index ["order_id"], name: "index_items_on_order_id"
  end

  create_table "order_details", force: :cascade do |t|
    t.integer "order_id", null: false
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
    t.index ["order_id"], name: "index_order_details_on_order_id"
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

  create_table "posts", force: :cascade do |t|
    t.string "title"
    t.string "description"
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

  create_table "uploaded_files", force: :cascade do |t|
    t.string "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bom_raw_materials", "boms"
  add_foreign_key "boms", "item_masters"
  add_foreign_key "items", "orders"
  add_foreign_key "order_details", "orders"
end
