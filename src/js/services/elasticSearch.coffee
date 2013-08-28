angular.module('Courses.services')
.factory 'elasticSearch', (ejsResource) ->
  ES_URL = 'http://db.data.adicu.com:9200'
  resource = ejsResource(ES_URL)
  request = resource.Request().indices('jdbc')

  executeCourseQuery: (query, term) ->
    elasticSearch
      .query(
          ejs.BoolQuery()
          .must(ejs.WildcardQuery('term', '*' + term  + '*'))
          .should(ejs.QueryStringQuery(query + '*')
            .fields(['coursetitle^3', 'course^4', 'description',
              'coursesubtitle', 'instructor^2']))
          .should(ejs.QueryStringQuery('*' + query + '*')
            .fields(['course', 'coursefull']))
          .minimumNumberShouldMatch(1)
      )
      .doSearch()
      .then (data) ->
        processedResults = CalendarUtil.processQueryResults data
        d.resolve processedResults
