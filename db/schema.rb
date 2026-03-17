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

ActiveRecord::Schema[8.0].define(version: 2026_03_17_190350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "ai_conversations", force: :cascade do |t|
    t.string "session_id", null: false
    t.string "user_type"
    t.string "user_region"
    t.text "messages"
    t.string "status", default: "active"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_ai_conversations_on_created_at"
    t.index ["session_id", "status"], name: "index_ai_conversations_on_session_id_and_status"
    t.index ["session_id"], name: "index_ai_conversations_on_session_id"
    t.index ["status"], name: "index_ai_conversations_on_status"
    t.index ["user_region"], name: "index_ai_conversations_on_user_region"
    t.index ["user_type", "user_region"], name: "index_ai_conversations_on_user_type_and_user_region"
    t.index ["user_type"], name: "index_ai_conversations_on_user_type"
  end

  create_table "ai_insights", force: :cascade do |t|
    t.string "insight_type", null: false
    t.json "content"
    t.decimal "confidence_score", precision: 5, scale: 4, default: "0.0"
    t.json "input_data"
    t.string "ai_model", default: "gpt-4"
    t.json "ai_metadata"
    t.string "status", default: "pending", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "error_message"
    t.bigint "prime_id"
    t.bigint "calculation_id"
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_id"], name: "index_ai_insights_on_calculation_id"
    t.index ["confidence_score"], name: "index_ai_insights_on_confidence_score"
    t.index ["created_at"], name: "index_ai_insights_on_created_at"
    t.index ["insight_type"], name: "index_ai_insights_on_insight_type"
    t.index ["prime_id"], name: "index_ai_insights_on_prime_id"
    t.index ["status", "insight_type"], name: "index_ai_insights_on_status_and_insight_type"
    t.index ["status"], name: "index_ai_insights_on_status"
  end

  create_table "calculations", force: :cascade do |t|
    t.string "calculation_type", null: false
    t.json "input_params", null: false
    t.json "result"
    t.string "status", default: "pending", null: false
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "error_message"
    t.bigint "prime_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_type"], name: "index_calculations_on_calculation_type"
    t.index ["created_at"], name: "index_calculations_on_created_at"
    t.index ["prime_id"], name: "index_calculations_on_prime_id"
    t.index ["status", "calculation_type"], name: "index_calculations_on_status_and_calculation_type"
    t.index ["status"], name: "index_calculations_on_status"
  end

  create_table "contact_submissions", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.string "email"
    t.string "phone"
    t.string "region"
    t.text "message"
    t.string "status"
    t.json "metadata"
    t.datetime "submitted_at"
    t.datetime "processed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "address"
    t.string "city"
    t.string "postal_code"
    t.integer "surface_area"
    t.string "timeline"
    t.string "priority"
    t.string "current_heating"
    t.string "income_range"
    t.string "project_scale"
    t.string "target_market"
    t.datetime "read_at"
    t.string "ip_address"
    t.text "user_agent"
    t.string "first_name"
    t.string "last_name"
    t.string "property_type"
    t.string "work_type"
    t.string "submission_type"
    t.integer "construction_year"
    t.decimal "estimated_budget"
    t.string "realization_deadline"
    t.integer "number_of_units"
    t.string "building_type"
    t.string "building_work_type"
    t.decimal "voted_budget"
    t.string "work_urgency"
    t.string "business_activity"
    t.string "investment_region"
    t.string "company_size"
    t.text "syndic_contact"
    t.index ["city"], name: "index_contact_submissions_on_city"
    t.index ["postal_code"], name: "index_contact_submissions_on_postal_code"
  end

  create_table "page_visits", force: :cascade do |t|
    t.string "visitor_id"
    t.string "page_path"
    t.string "referrer"
    t.text "user_agent"
    t.string "ip_address"
    t.string "user_region"
    t.string "device_type"
    t.string "session_id"
    t.integer "time_on_page"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "primes", force: :cascade do |t|
    t.bigint "value", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_primes_on_created_at"
    t.index ["position"], name: "index_primes_on_position", unique: true
    t.index ["value"], name: "index_primes_on_value", unique: true
  end

  create_table "security_logs", force: :cascade do |t|
    t.string "event_type"
    t.string "severity"
    t.string "ip_address"
    t.text "user_agent"
    t.jsonb "details"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "ai_insights", "calculations"
  add_foreign_key "ai_insights", "primes"
  add_foreign_key "calculations", "primes"
end
