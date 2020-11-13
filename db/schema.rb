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

ActiveRecord::Schema.define(version: 20201111061620) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_end_time"
    t.datetime "overtime"
    t.string "business_content"
    t.string "directions"
    t.string "check_overtime_apply"
    t.string "check_edit_one_month"
    t.string "month_request_status"
    t.string "attendance_approved"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "name"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.boolean "superior", default: false
    t.string "affiliation"
    t.datetime "basic_time", default: "2020-11-11 23:00:00"
    t.datetime "work_time", default: "2020-11-11 22:30:00"
    t.datetime "designated_work_start_time", default: "2020-11-12 00:00:00"
    t.datetime "designated_work_end_time", default: "2020-11-12 09:00:00"
    t.string "employee_number"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
