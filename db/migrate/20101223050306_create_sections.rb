class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.string :title
      t.integer :call_number
      t.text :description
      t.string :days
      t.time :start_time
      t.time :end_time
      t.string :room
      t.string :building
      t.integer :instructor_id
      t.integer :department_id
      t.integer :subject_id
      t.integer :section_number
      t.string :section_key
      t.integer :course_id
      t.string :semester
      t.string :url
      t.integer :enrollment
      t.integer :max_enrollment
      
      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
