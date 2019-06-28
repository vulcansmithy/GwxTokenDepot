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

ActiveRecord::Schema.define(version: 2019_06_28_075129) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "top_up_transactions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "transaction_type"
    t.string "top_up_receiving_wallet_address"
    t.string "top_up_transaction_hash"
    t.datetime "top_up_transaction_at"
    t.string "gwx_wallet_address"
    t.string "gwx_transaction_hash"
    t.datetime "gwx_transaction_at"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "bip32_address_path"
    t.decimal "quantity_to_receive", precision: 10, scale: 8
    t.decimal "gwx_to_transfer", precision: 8, scale: 6
  end

end
