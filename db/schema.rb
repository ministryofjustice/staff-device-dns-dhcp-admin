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

ActiveRecord::Schema.define(version: 2021_10_28_095031) do

  create_table "audits", charset: "latin1", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.json "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "client_classes", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "client_id", null: false
    t.string "domain_name_servers", null: false
    t.string "domain_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_client_classes_on_client_id", unique: true
    t.index ["name"], name: "index_client_classes_on_name", unique: true
  end

  create_table "exclusions", charset: "latin1", force: :cascade do |t|
    t.string "start_address"
    t.string "end_address"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "subnet_id", null: false
    t.index ["subnet_id"], name: "index_exclusions_on_subnet_id"
  end

  create_table "global_options", charset: "latin1", force: :cascade do |t|
    t.string "domain_name_servers", null: false
    t.string "domain_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "valid_lifetime", unsigned: true
    t.string "valid_lifetime_unit"
  end

  create_table "options", charset: "latin1", force: :cascade do |t|
    t.string "domain_name_servers"
    t.string "domain_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "subnet_id", null: false
    t.integer "valid_lifetime", unsigned: true
    t.string "valid_lifetime_unit"
    t.index ["subnet_id"], name: "index_options_on_subnet_id"
  end

  create_table "reservation_options", charset: "latin1", force: :cascade do |t|
    t.string "domain_name"
    t.string "routers"
    t.bigint "reservation_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reservation_id"], name: "index_reservation_options_on_reservation_id"
  end

  create_table "reservations", charset: "latin1", force: :cascade do |t|
    t.bigint "subnet_id", null: false
    t.string "hw_address"
    t.string "ip_address"
    t.string "hostname"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["subnet_id"], name: "index_reservations_on_subnet_id"
  end

  create_table "shared_networks", charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "site_id"
    t.index ["site_id"], name: "index_shared_networks_on_site_id"
  end

  create_table "sites", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "fits_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subnets", charset: "latin1", force: :cascade do |t|
    t.string "cidr_block", null: false
    t.string "start_address", null: false
    t.string "end_address", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "routers", null: false
    t.bigint "shared_network_id"
    t.index ["shared_network_id"], name: "index_subnets_on_shared_network_id"
  end

  create_table "users", charset: "latin1", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.boolean "editor", default: false
    t.string "email"
    t.integer "role", default: 0, null: false
  end

  create_table "zones", charset: "latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "forwarders", null: false
    t.string "purpose"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "exclusions", "subnets"
  add_foreign_key "options", "subnets"
  add_foreign_key "reservation_options", "reservations"
  add_foreign_key "reservations", "subnets"
  add_foreign_key "shared_networks", "sites"
  add_foreign_key "subnets", "shared_networks"
end
