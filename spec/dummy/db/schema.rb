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

ActiveRecord::Schema.define(version: 20150806215036) do

  create_table "flyover_comments_comments", force: :cascade do |t|
    t.text     "content"
    t.integer  "ident_user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "parent_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "flyover_comments_comments", ["commentable_type", "commentable_id"], name: "idx_flyover_comments_comments_commentable_type_commentable_id"
  add_index "flyover_comments_comments", ["ident_user_id"], name: "index_flyover_comments_comments_on_ident_user_id"
  add_index "flyover_comments_comments", ["parent_id"], name: "index_flyover_comments_comments_on_parent_id"

  create_table "flyover_comments_flags", force: :cascade do |t|
    t.integer  "comment_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "flyover_comments_flags", ["comment_id"], name: "index_flyover_comments_flags_on_comment_id"
  add_index "flyover_comments_flags", ["user_id"], name: "index_flyover_comments_flags_on_user_id"

  create_table "ident_users", force: :cascade do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ident_users", ["email"], name: "index_ident_users_on_email", unique: true
  add_index "ident_users", ["reset_password_token"], name: "index_ident_users_on_reset_password_token", unique: true

  create_table "posts", force: :cascade do |t|
    t.integer  "ident_user_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "posts", ["ident_user_id"], name: "index_posts_on_ident_user_id"

end
