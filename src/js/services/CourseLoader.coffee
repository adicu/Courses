angular.module('Courses.services')
.factory 'CourseLoader', ($http, $q, elasticSearch, Section) ->
  @load: (query, semester, calendar) ->
      d = $q.defer()
      if query.match /^\d{5}$/
        callnum = parseInt query, 10
        s = new Section callnum, semester
        s.fillData(Course).then (status) ->
          calendar.sectionChosen s
          calendar.updateURL()
        d.resolve 'callnum'
        d.promise
      else
        Course.elasticSearch
          .query(
              ejs.BoolQuery()
              .must(ejs.WildcardQuery('term', '*' + semester  + '*'))
              .should(ejs.QueryStringQuery(query + '*')
                .fields(['coursetitle^3', 'course^4', 'description',
                  'coursesubtitle', 'instructor^2']))
              .should(ejs.QueryStringQuery('*' + query + '*')
                .fields(['course', 'coursefull']))
              .minimumNumberShouldMatch(1)
          )
          .doSearch().then (data) ->
            return if not data? and not data.hits? and data.hits.hits?
            hits = data.hits.hits
            new Course hit._source.course, semester, hit._source for hit in hits