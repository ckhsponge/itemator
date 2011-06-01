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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110601215424) do

  create_table "docs", :force => true do |t|
    t.string   "path",       :default => "", :null => false
    t.string   "folder",     :default => "", :null => false
    t.string   "title",      :default => "", :null => false
    t.string   "key",        :default => "", :null => false
    t.string   "status",     :default => "", :null => false
    t.boolean  "parsed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "success_at"
  end

  add_index "docs", ["path"], :name => "index_docs_on_path", :unique => true

end
