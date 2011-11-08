class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors do |t|
      t.string :name
    end
  end

  def self.down
    drop_table :instructors
  end
end
