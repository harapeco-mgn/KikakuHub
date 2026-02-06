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

ActiveRecord::Schema[7.2].define(version: 2026_02_06_120627) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "availability_slots", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "category", null: false
    t.integer "wday", null: false
    t.integer "start_minute", null: false
    t.integer "end_minute", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "category", "wday", "start_minute", "end_minute"], name: "index_availability_slots_unique_range", unique: true
    t.index ["user_id"], name: "index_availability_slots_on_user_id"
    t.check_constraint "(end_minute % 30) = 0", name: "chk_availability_slots_end_step_30"
    t.check_constraint "(start_minute % 30) = 0", name: "chk_availability_slots_start_step_30"
    t.check_constraint "category = ANY (ARRAY[0, 1])", name: "chk_availability_slots_category"
    t.check_constraint "end_minute > 0 AND end_minute <= 1440", name: "chk_availability_slots_end_range"
    t.check_constraint "end_minute > start_minute", name: "chk_availability_slots_end_after_start"
    t.check_constraint "start_minute >= 0 AND start_minute < 1440", name: "chk_availability_slots_start_range"
    t.check_constraint "wday >= 0 AND wday <= 6", name: "chk_availability_slots_wday"
  end

  create_table "communities", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rsvps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.integer "status"
    t.boolean "secondary_interest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_rsvps_on_theme_id"
    t.index ["user_id"], name: "index_rsvps_on_user_id"
  end

  create_table "theme_comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_theme_comments_on_theme_id"
    t.index ["user_id"], name: "index_theme_comments_on_user_id"
  end

  create_table "theme_votes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "theme_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["theme_id"], name: "index_theme_votes_on_theme_id"
    t.index ["user_id", "theme_id"], name: "index_theme_votes_on_user_id_and_theme_id", unique: true
    t.index ["user_id"], name: "index_theme_votes_on_user_id"
  end

  create_table "themes", force: :cascade do |t|
    t.bigint "community_id", null: false
    t.bigint "user_id", null: false
    t.integer "category"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "secondary_enabled", default: false, null: false
    t.string "secondary_label"
    t.integer "theme_votes_count", default: 0, null: false
    t.index ["community_id"], name: "index_themes_on_community_id"
    t.index ["user_id"], name: "index_themes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "nickname", default: "ユーザー", null: false
    t.integer "cohort", default: 0, null: false
    t.index ["cohort"], name: "index_users_on_cohort"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "availability_slots", "users"
  add_foreign_key "rsvps", "themes"
  add_foreign_key "rsvps", "users"
  add_foreign_key "theme_comments", "themes"
  add_foreign_key "theme_comments", "users"
  add_foreign_key "theme_votes", "themes"
  add_foreign_key "theme_votes", "users"
  add_foreign_key "themes", "communities"
  add_foreign_key "themes", "users"
end
