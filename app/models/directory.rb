class Directory
  def self.crawl
    require 'open-uri'

    subjects = Subject.order( "id" ).all
    num_subjects = subjects.size

    #Section.update_or_create "http://www.columbia.edu/cu/bulletin/uwb/subj/POLS/BC3118-20111-001/"

#=begin
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