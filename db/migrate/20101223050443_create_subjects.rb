class CreateSubjects < ActiveRecord::Migration
  def self.up
    create_table :subjects do |t|
      t.string :title
      t.string :abbreviation
    end
  end

  def self.down
    drop_table :subjects
  end
end
