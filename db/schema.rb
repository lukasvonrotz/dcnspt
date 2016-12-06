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

ActiveRecord::Schema.define(version: 20161202150103) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "criterioncontexts", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "criterionparams", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "criterion_id"
    t.decimal  "weight"
    t.decimal  "preferencethreshold"
    t.decimal  "indifferencethreshold"
    t.decimal  "vetothreshold"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criterionparams", ["criterion_id"], name: "index_criterionparams_on_criterion_id", using: :btree
  add_index "criterionparams", ["project_id"], name: "index_criterionparams_on_project_id", using: :btree

  create_table "criterions", force: :cascade do |t|
    t.integer  "criterioncontext_id"
    t.string   "name"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "criterions", ["criterioncontext_id"], name: "index_criterions_on_criterioncontext_id", using: :btree

  create_table "criterionvalues", force: :cascade do |t|
    t.integer  "employee_id"
    t.integer  "criterion_id"
    t.decimal  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "criterionvalues", ["criterion_id"], name: "index_criterionvalues_on_criterion_id", using: :btree
  add_index "criterionvalues", ["employee_id"], name: "index_criterionvalues_on_employee_id", using: :btree

  create_table "employees", force: :cascade do |t|
    t.string   "firstname"
    t.string   "surname"
    t.decimal  "loclat"
    t.decimal  "loclon"
    t.string   "country"
    t.decimal  "costrate"
    t.string   "jobprofile"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees_projects", id: false, force: :cascade do |t|
    t.integer "project_id",  null: false
    t.integer "employee_id", null: false
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

  add_index "projects", ["user_id"], name: "index_projects_on_user_id", using: :btree

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

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

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

  add_index "workloads", ["employee_id"], name: "index_workloads_on_employee_id", using: :btree
  add_index "workloads", ["week_id"], name: "index_workloads_on_week_id", using: :btree

  add_foreign_key "projects", "users"
end
