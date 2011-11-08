class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string :name
      t.string :abbreviation
    end
  end

  def self.down
    drop_table :schools
  end
end
