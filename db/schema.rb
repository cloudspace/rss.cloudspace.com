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

ActiveRecord::Schema.define(version: 20141107164849) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "feed_items", force: true do |t|
    t.text     "title"
    t.text     "url"
    t.text     "author"
    t.text     "summary"
    t.text     "content"
    t.datetime "published_at"
    t.integer  "feed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "processed",          default: false
    t.boolean  "processing",         default: false
    t.text     "image_url"
    t.boolean  "image_processing",   default: false
    t.datetime "process_start"
    t.datetime "process_end"
    t.boolean  "scheduled"
  end

  add_index "feed_items", ["feed_id"], name: "index_feed_items_on_feed_id", using: :btree
  add_index "feed_items", ["processed"], name: "index_feed_items_on_processed", using: :btree
  add_index "feed_items", ["processing"], name: "index_feed_items_on_processing", using: :btree

  create_table "feeds", force: true do |t|
    t.text     "name"
    t.text     "site_url"
    t.text     "url"
    t.text     "summary"
    t.string   "etag"
    t.datetime "last_modified_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "default",             default: false
    t.boolean  "approved",            default: true
    t.boolean  "processing",          default: false
    t.datetime "last_parsed_at"
    t.datetime "next_parse_at"
    t.integer  "parse_backoff_level", default: 0
    t.json     "parser_options"
    t.datetime "process_start"
    t.datetime "process_end"
    t.boolean  "scheduled"
  end

  add_index "feeds", ["approved"], name: "index_feeds_on_approved", using: :btree
  add_index "feeds", ["default"], name: "index_feeds_on_default", using: :btree
  add_index "feeds", ["last_modified_at"], name: "index_feeds_on_last_modified_at", using: :btree
  add_index "feeds", ["last_parsed_at"], name: "index_feeds_on_last_parsed_at", using: :btree
  add_index "feeds", ["name"], name: "index_feeds_on_name", using: :btree
  add_index "feeds", ["next_parse_at"], name: "index_feeds_on_next_parse_at", using: :btree
  add_index "feeds", ["processing"], name: "index_feeds_on_processing", using: :btree

  create_table "worker_errors", force: true do |t|
    t.string   "element_type"
    t.integer  "element_id"
    t.text     "element_state"
    t.text     "message"
    t.text     "backtrace"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "exception_class"
  end

  add_index "worker_errors", ["element_id"], name: "index_worker_errors_on_element_id", using: :btree
  add_index "worker_errors", ["element_type"], name: "index_worker_errors_on_element_type", using: :btree
  add_index "worker_errors", ["exception_class"], name: "index_worker_errors_on_exception_class", using: :btree

end
