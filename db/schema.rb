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

ActiveRecord::Schema[7.0].define(version: 2023_12_20_085421) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "planning_aircrafts", force: :cascade do |t|
    t.string "type", null: false
    t.string "registration_number", null: false
    t.bigint "for_reservation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["for_reservation_id"], name: "index_planning_aircrafts_on_for_reservation_id"
    t.index ["registration_number"], name: "index_planning_aircrafts_on_registration_number"
  end

  create_table "planning_pilots", primary_key: "pilot_id", id: :string, force: :cascade do |t|
    t.json "licenses", null: false
    t.bigint "for_reservation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["for_reservation_id"], name: "index_planning_pilots_on_for_reservation_id"
  end

  create_table "planning_planning_days", force: :cascade do |t|
    t.date "day", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day"], name: "index_planning_planning_days_on_day", unique: true
  end

  create_table "planning_reservations", force: :cascade do |t|
    t.string "reservation_number"
    t.boolean "canceled", default: false
    t.bigint "for_planning_day_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["for_planning_day_id"], name: "index_planning_reservations_on_for_planning_day_id"
    t.index ["reservation_number"], name: "index_planning_reservations_on_reservation_number"
  end

  add_foreign_key "planning_aircrafts", "planning_reservations", column: "for_reservation_id"
  add_foreign_key "planning_pilots", "planning_reservations", column: "for_reservation_id"
  add_foreign_key "planning_reservations", "planning_planning_days", column: "for_planning_day_id"
end
