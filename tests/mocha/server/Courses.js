describe('Courses', function() {
  before(function() {
    stubMeteor();
  });

  it('should full text search', function(done) {
    Meteor.call(
      'Courses/search',
      'COMS',
      '20143',
      function(err, result) {
        if (err) {
          throw err;
        }
        assert(result, 'results are returned');
        done();
      }
    );
  });

  it('should get associated sections', function() {
    var aCourse = Courses.findOne({'courseFull' : 'COMSW1007'});
    assert(aCourse, 'got some course');

    var sectionCount = aCourse.getSections().count();
    assert(sectionCount, 'sections are returned');
  });
});
