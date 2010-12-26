class CreateInstructors < ActiveRecord::Migration
  def self.up
    create_table :instructors do |t|
      t.string :name
      t.culpa_url :string
      t.culpa_rating :string
      t.timestamps
    end
  end

  def self.down
    drop_table :instructors
  end
end
