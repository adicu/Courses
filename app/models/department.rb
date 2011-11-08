class Department < ActiveRecord::Base
  has_many :sections
  has_many :courses
  
  BASE_URL = "http://www.college.columbia.edu/unify/bulletinText/"

  def get_bulletin
    require 'open-uri'
    url = BASE_URL + self.abbreviation + "/xml"

    begin
      doc = Nokogiri::XML(open( url ))
      return doc.content
    rescue
      puts "Bad bulletin url: " << url
      return nil
    end
  end
end
