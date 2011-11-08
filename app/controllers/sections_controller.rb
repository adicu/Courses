class SectionsController < ApplicationController

  def get
    call_numbers = params[:call_number].kind_of?( Hash ) ? params[:call_number].values[0..99] : array( params[:call_number] )
    semester = params[:s].nil? ? currentSemester : params[:s]
    output = []
    call_numbers.each do |call_number|
      s = Section.find_by_call_number_and_semester( call_number, semester )
      s_data = {}

      unless s.instructor.nil?
        instructor = { 
          :id => s.instructor.id, 
          :name => s.instructor.name, 
        }
      else
        instructor = nil
      end
    
      s_data[:id] = s.id
      s_data[:title] = s.title
      s_data[:call_number] = s.call_number
      s_data[:description] = s.description
      s_data[:section_number] = s.section_number
      s_data[:section_key] = s.section_key
      s_data[:enrollment] = s.enrollment
      s_data[:max_enrollment] = s.max_enrollment
      s_data[:url] = s.url
      s_data[:instructor] = instructor
      s_data[:building] = s.building
      s_data[:room] = s.room
      s_data[:start] = s.start_time
      s_data[:end] = s.end_time
      s_data[:days] = s.days
      s_data[:course] = { :id => s.course.id, :title => s.course.title, :course_key => s.course.course_key, :description => s.course.description, :num_sections => s.course.sections.size } unless s.course.nil?
      output << s_data
    end
      
    render :json => output, :callback => params[:callback]
  end

  private
  def currentSemester
    month = Time.now.month
    year = Time.now.year

    if month > 11
      month %= 12
      year += 1
    end

    return year.to_s + (month/4+1).to_s
  end

end
