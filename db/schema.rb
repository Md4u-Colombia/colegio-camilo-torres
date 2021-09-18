# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150403005021) do

  create_table "areas", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "status",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "business_units", force: true do |t|
    t.string   "name"
    t.boolean  "status",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", force: true do |t|
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "contact"
    t.integer  "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "education_levels", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "status",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "localizations", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.boolean  "status",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "position_levels", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "positions", force: true do |t|
    t.string   "name"
    t.integer  "position_level_id"
    t.text     "description"
    t.boolean  "status",            default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name",                   default: "", null: false
    t.string   "last_name",              default: "", null: false
    t.integer  "identity",               default: 0,  null: false
    t.integer  "gender",                 default: 0,  null: false
    t.time     "since_date"
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.integer  "company_id",             default: 0,  null: false
    t.integer  "area_id",                default: 0,  null: false
    t.integer  "localization_id",        default: 0,  null: false
    t.integer  "position_id",            default: 0,  null: false
    t.integer  "group_id",               default: 0,  null: false
    t.integer  "business_unite_id",      default: 0,  null: false
    t.integer  "country_id",             default: 0,  null: false
    t.integer  "city_id",                default: 0,  null: false
    t.integer  "status",                 default: 1,  null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "role_id",                default: 0,  null: false
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
