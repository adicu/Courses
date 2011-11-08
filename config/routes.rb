ScheduleBuilder::Application.routes.draw do
  match "courses/search/", :to => "courses#search"
  match "courses/get/", :to => "courses#get"
  match "sections/get/", :to => "sections#get"
end
