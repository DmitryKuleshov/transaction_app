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

ActiveRecord::Schema.define(version: 2019_04_08_113623) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bank_accounts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "currency_id"
    t.index ["currency_id"], name: "index_bank_accounts_on_currency_id"
    t.index ["user_id"], name: "index_bank_accounts_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "iso"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "currencies", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "wallet_id"
    t.integer "from_wallet_id"
    t.integer "to_wallet_id"
    t.float "balance"
    t.index ["wallet_id"], name: "index_transactions_on_wallet_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "country_id"
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "wallets", force: :cascade do |t|
    t.float "balance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "currency_id"
    t.boolean "active", default: false
    t.bigint "bank_account_id"
    t.boolean "active", default: false
    t.index ["bank_account_id"], name: "index_wallets_on_bank_account_id"
    t.index ["currency_id"], name: "index_wallets_on_currency_id"
  end

  add_foreign_key "bank_accounts", "currencies"
  add_foreign_key "bank_accounts", "users"
  add_foreign_key "transactions", "wallets"
  add_foreign_key "users", "countries"
  add_foreign_key "wallets", "bank_accounts"
  add_foreign_key "wallets", "currencies"
end
