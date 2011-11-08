class Directory
  
  def self.crawl
    require 'open-uri'


#=begin
    subjects = Subject.order( "id" )
    num_subjects = subjects.size

    subjects.each_with_index do |s, index|
      unless s.abbreviation.nil?
        url = "http://www.columbia.edu/cu/bulletin/uwb/subj/" + s.abbreviation
        puts "(" << (index+1).to_s << " of " << num_subjects.to_s << "): " << url
                
        begin
          doc = Nokogiri::HTML(open(url))
        rescue
          puts "\t\tBad subject URL"
          next
        end

        doc.css('a').each { |a| Section.update_or_create( url + "/" + a.content ) if a.content =~ /[A-Z0-9]+-[0-9]+-[0-9]+/ }
      end
    end
#=end
  end
end
