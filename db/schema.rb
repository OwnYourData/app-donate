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

ActiveRecord::Schema.define(version: 20180823231700) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "donation_records", force: :cascade do |t|
    t.integer "donation_id"
    t.string "key_id"
    t.text "submission"
    t.integer "privacy"
    t.string "email"
    t.boolean "diffpriv"
    t.string "recipient"
    t.string "purpose"
    t.string "processing"
    t.boolean "min_participants"
    t.integer "min_participants_number"
    t.string "storage_location"
    t.string "storage_duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "signature"
  end

  create_table "donations", force: :cascade do |t|
    t.string "name"
    t.string "container"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
