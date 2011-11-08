class CoursesController < ApplicationController

  def search
    per_page = params[:l].nil? or params[:l].to_i > 100 ? 10 : params[:l]
    page = params[:p].nil? ? 1 : params[:p]
    semester = params[:s].nil? ? currentSemester : params[:s]

    output = {}

    params[:q] = refine_query(params[:q])

    output[:num_results] = Course.search_count params[:q],
        :with => { :semesters => semester }
    results = Course.search(params[:q], :with => { :semesters => semester },
        :page => page, :per_page => per_page)
    output[:results] = results.select { |r|
      !r.nil?
    }.collect { |c|
      { "id" => c.id,
        "course_key" => c.course_key,
        :title => c.title,
        :description => c.description,
        :num_sections => c.sections.size
      }
    }
    render :json => output, :callback => params[:callback]
  end

  def get
    c = Course.find_by_course_key( params[:course_key] )

    if c.nil?
      render :json => { }, :callback => params[:callback]
    end

    semester = params[:s].nil? ? currentSemester : params[:s]
    output = { :title => c.title, :course_key => c.course_key, :description => c.description, :points => c.points, :id => c.id }
    output[:sections] = []

    c.sections.each do |s|

      next if s.semester != semester

      unless s.instructor.nil?
        instructor = {
          :id => s.instructor.id,
          :name => s.instructor.name,
        }
      else
        instructor = nil
      end

      output[:sections] << {
        :id => s.id,
        :title => s.title,
        :call_number => s.call_number,
        :description => s.description,
        :section_number => s.section_number,
        :section_key => s.section_key,
        :enrollment => s.enrollment,
        :max_enrollment => s.max_enrollment,
        :url => s.url,
        :instructor => instructor,
        :building => s.building,
        :room => s.room,
        :start => s.start_time,
        :end => s.end_time,
        :days => s.days
      }
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

  def refine_query(str)
    str.gsub(/\bhum\b/, "humanities")
  end

end
