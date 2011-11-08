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

ActiveRecord::Schema.define(:version => 20101223050443) do

  create_table "courses", :force => true do |t|
    t.string   "title"
    t.string   "course_key"
    t.text     "description"
    t.float    "points"
    t.datetime "updated_at"
  end

  create_table "departments", :force => true do |t|
    t.string "title"
    t.string "abbreviation"
  end

  create_table "instructors", :force => true do |t|
    t.string "name"
  end

  create_table "schools", :force => true do |t|
    t.string "name"
    t.string "abbreviation"
  end

  create_table "sections", :force => true do |t|
    t.string  "title"
    t.integer "call_number"
    t.text    "description"
    t.string  "days"
    t.float   "start_time"
    t.float   "end_time"
    t.string  "room"
    t.string  "building"
    t.integer "instructor_id"
    t.integer "department_id"
    t.integer "subject_id"
    t.integer "section_number"
    t.string  "section_key"
    t.integer "course_id"
    t.string  "semester"
    t.string  "url"
    t.integer "enrollment"
    t.integer "max_enrollment"
  end

  create_table "subjects", :force => true do |t|
    t.string "title"
    t.string "abbreviation"
  end

end
