angular.module('Courses.services')
.factory 'elasticSearch', (ejsResource) ->
  resource = ejsResource('http://db.data.adicu.com:9200')
  request = resource.Request().indices('jdbc')
