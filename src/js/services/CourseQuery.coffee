angular.module('Courses.services')
.factory 'CourseQuery', (
  $q,
  Course,
  Section,
) ->
  @source = ''
  from: (source) ->
    @source = source

  
