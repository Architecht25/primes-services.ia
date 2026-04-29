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

ActiveRecord::Schema[8.0].define(version: 2026_04_29_000000) do
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

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.binary "key", null: false
    t.binary "value", null: false
    t.datetime "created_at", null: false
    t.bigint "key_hash", null: false
    t.integer "byte_size", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  add_foreign_key "ai_insights", "calculations"
  add_foreign_key "ai_insights", "primes"
  add_foreign_key "calculations", "primes"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
end
