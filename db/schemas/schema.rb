# -*- mode: ruby -*-
# vi: set ft=ruby :
create_table "cats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
  t.string "name", null: false
  t.integer "age", null: false
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
