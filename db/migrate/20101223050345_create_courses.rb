class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :title
      t.string :course_key
      t.text :description
      t.float :points
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :courses
  end
end
