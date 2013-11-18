angular.module('Courses.services')
.factory 'elasticSearch', (
  CONFIG,
  ejsResource,
) ->
  ejs = ejsResource CONFIG.ES_API

  ejs: ejs

  getCourseRequest: () ->
    request = ejs.Request()
      .indices('data')
      .types('courses')
