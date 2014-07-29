Template.about.courseContributors = function() {
  var now = moment();
  var previous = moment().subtract(1, 'year');

  var format = 'YYYY-MM-DD';
  var urlBase = 'https://github.com/adicu/Courses/graphs/contributors?from=';

  return urlBase + previous.format(format) + '&to=' + now.format(format) +
    '&type=c';
};
