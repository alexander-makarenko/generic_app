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

ActiveRecord::Schema.define(version: 20151123142742) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "auth_digest"
    t.string   "email_confirmation_digest"
    t.boolean  "email_confirmed",            default: false
    t.datetime "email_confirmed_at"
    t.datetime "email_confirmation_sent_at"
    t.string   "password_reset_digest"
    t.datetime "password_reset_sent_at"
    t.string   "last_name"
    t.hstore   "preferences"
    t.string   "old_email"
    t.boolean  "old_email_confirmed",        default: false
    t.datetime "old_email_confirmed_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "admin",                      default: false
    t.datetime "last_seen_at"
  end

  add_index "users", ["auth_digest"], name: "index_users_on_auth_digest", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
