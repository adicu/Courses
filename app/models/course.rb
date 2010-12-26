class Course < ActiveRecord::Base
  has_many :sections
  belongs_to :subject
  belongs_to :department
  
  def self.update_or_create( url )
    require 'open-uri'
    error_message = "I'm sorry. At the moment, there are no courses that correspond to your search criteria."

    # initialize course by course key
    match = url.match( /courseIdentifierVar=([A-Z0-9]+)/ )
  
    course = Course.find_by_course_key( match[1] )
    return course unless course.nil?

    begin
      doc = Nokogiri::HTML(open( url ))
      return nil if doc.to_html.match( error_message )
    rescue
      puts "Bad course url: " << url
      return nil
    end

    brief = ""
    doc.css( "div.course-description > p" ).each do |p|
      if p.to_html.gsub( "\n", "" ).match( /<strong>.*<\/strong>/ )
        brief = p.to_html.gsub( "\n", "" ).gsub(/<em>Not offered in [0-9]+-[0-9]+.<\/em>/, "").gsub( /\s+/, " " ).gsub( /&amp;/, "&" ).strip
        break
      end
    end

    course = Course.new
    course.course_key = match[1]

    puts url

    # title
    match = brief.match( /<strong>(.+)<\/strong>/ )
    course.title = match[1].gsub( /<\/?[^>]*>/, " " ).gsub( /([A-Z]+ )?[A-Z]+[0-9]+(x|y)?( and y| or y)?-?(\s*\*\s*)?/, "" ).gsub( /\s+/, " " ).strip

    # description
    match = brief.match( /<\/strong>\s*(<em>\s*[0-9.]+\s*pts\.\s*<\/em>)?\s*(.*)$/ )
    course.description = match[2].gsub(/<\/?[^>]*>/, " ").gsub( /\s+/, " " ).strip

    # points
    match = brief.match( /<em>\s*([0-9.]+)\s*pts\.\s*<\/em>/ )
    course.points = match[1].gsub(/<\/?[^>]*>/, " ").gsub( /\s+/, " " ).strip unless match.nil?

    course.save!
    return course
  end
end
