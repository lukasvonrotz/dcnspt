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

ActiveRecord::Schema.define(version: 20170523072543) do

  create_table "criterioncontexts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "criterionparams", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "criterion_id"
    t.decimal  "weight",       default: 0.1
    t.boolean  "direction",    default: true
    t.decimal  "prefthresslo", default: 0.1
    t.decimal  "prefthresint", default: 0.1
    t.decimal  "inthresslo",   default: 0.1
    t.decimal  "inthresint",   default: 0.1
    t.decimal  "vetothresslo", default: 0.1
    t.decimal  "vetothresint", default: 0.1
    t.decimal  "filterlow",    default: 0.0
    t.decimal  "filterhigh",   default: 100000.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criterionparams", ["criterion_id"], name: "index_criterionparams_on_criterion_id"
  add_index "criterionparams", ["project_id"], name: "index_criterionparams_on_project_id"

  create_table "criterions", force: :cascade do |t|
    t.integer  "criterioncontext_id"
    t.string   "name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "criterions", ["criterioncontext_id"], name: "index_criterions_on_criterioncontext_id"

  create_table "criterionvalues", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "criterion_id"
    t.decimal  "value",        precision: 10, scale: 3
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criterionvalues", ["criterion_id"], name: "index_criterionvalues_on_criterion_id"
  add_index "criterionvalues", ["employee_id"], name: "index_criterionvalues_on_employee_id"

  create_table "employees", force: :cascade do |t|
    t.string   "code"
    t.string   "firstname"
    t.string   "surname"
    t.string   "city"
    t.decimal  "loclat"
    t.decimal  "loclon"
    t.string   "location"
    t.string   "country"
    t.decimal  "costrate"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "jobprofile_id"
  end

  add_index "employees", ["jobprofile_id"], name: "index_employees_on_jobprofile_id"

  create_table "employees_projects", id: false, force: :cascade do |t|
    t.integer "project_id",  null: false
    t.integer "employee_id", null: false
  end

  create_table "jobprofiles", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.decimal  "loclat"
    t.decimal  "loclon"
    t.datetime "startdate"
    t.datetime "enddate"
    t.decimal  "effort"
    t.decimal  "hourlyrate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id"

  create_table "sensitivities", force: :cascade do |t|
    t.float    "indslo"
    t.float    "indint"
    t.float    "prefslo"
    t.float    "prefint"
    t.float    "vetslo"
    t.float    "vetint"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "project_id"
    t.integer  "criterion_id"
    t.float    "weight"
  end

  add_index "sensitivities", ["criterion_id"], name: "index_sensitivities_on_criterion_id"
  add_index "sensitivities", ["project_id"], name: "index_sensitivities_on_project_id"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["context"], name: "index_taggings_on_context"
  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  add_index "taggings", ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
  add_index "taggings", ["taggable_id"], name: "index_taggings_on_taggable_id"
  add_index "taggings", ["taggable_type"], name: "index_taggings_on_taggable_type"
  add_index "taggings", ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id"

  create_table "tags", force: :cascade do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

  create_table "weeks", force: :cascade do |t|
    t.integer  "workweek"
    t.integer  "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workloads", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "week_id"
    t.decimal  "free"
    t.decimal  "offered"
    t.decimal  "sold"
    t.decimal  "absent"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "workloads", ["employee_id"], name: "index_workloads_on_employee_id"
  add_index "workloads", ["week_id"], name: "index_workloads_on_week_id"

end
