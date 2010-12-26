class Section < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
  belongs_to :department
  belongs_to :subject
  
  def self.update_or_create( url )
    require 'open-uri'
    
    begin
      doc = Nokogiri::HTML(open( url ))
    rescue
      puts "Bad section url"
      return nil
    end
    
    html = doc.to_html.gsub(/<\/?[^>]*>/, " ")

    # initialize section by section key
    match = html.match(/Section key\s*([^\n]+)/)
    section = Section.find_or_create_by_section_key( match[1].strip )
    match = section.section_key.match( /^[0-9]+([A-Z]+)/ )
    section.subject = Subject.find_or_create_by_abbreviation( match[1].strip )

    # section number
    match = doc.css("title").first.content.strip.match( /section\s*0*([0-9]+)/ )
    section.section_number = match[1].strip

    #title
    full_title = doc.css( 'td[colspan="2"]' )[1].to_html.gsub(/<\/?[^>]*>/, " ").strip
    title = doc.css("title").first.content.strip
    section.title = full_title.gsub( title, "" ).gsub( /\s+/, " " ).gsub( "&amp;", "&" ).strip

    #meta
    section.url = url
    section.semester = doc.css('meta[name="semes"]').first.attribute("content")
    section.description = doc.css('meta[name="description"]').first.attribute("content")
    
    instructor_name = doc.css('meta[name="instr"]').first.attribute("content").value.split( ", " )[0]
    section.instructor = Instructor.find_or_create_by_name( instructor_name )

    if html =~ /Department/
      match = html.match(/Department\s*([^\n]+)/)
      section.department = Department.find_or_create_by_title( match[1].strip )
    end

    if html =~ /Call Number/
      match = html.match(/Call Number\s*([^\n]+)/)
      section.call_number = match[1].strip
    end

    if html =~ /Day \&amp; Time Location/
      match = html.match(/Day \&amp; Time Location\s*([A-Za-z]+)\s*([^-]+)-([^\s]+)\s([^\n]+)/)
      section.days = match[1].strip
      section.start_time = Time.parse( match[2].strip )
      section.end_time = Time.parse( match[3].strip )
      if match[4].strip != "To be announced"
        match = match[4].strip.match( /([^\s]+)\s*(.+)/ )
        section.room = match[1].strip
        section.building = match[2].strip
      end
    end
    
    # course
    if html =~ /\n\s*Number\s*\n/
      match = html.match( /\n\s*Number\s*\n\s*([A-Z0-9]+)/ )
      url = "http://www.college.columbia.edu/unify/getApi/bulletinSearch.php?school=CC&courseIdentifierVar=" + section.subject.abbreviation + match[1]
      section.course = Course.update_or_create( url )
    end

    section.save!
    return section
  end
end
