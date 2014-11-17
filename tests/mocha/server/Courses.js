describe('Courses', function() {
  before(function() {
    stubMeteor();
  });

  it('should full text search', function(done) {
    Meteor.call(
      'Courses/search',
      'COMS',
      Session.get('currentSemester'),
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
    var aCourse = Courses.findOne({'courseFull' : 'COMSW1004'});
    assert(aCourse, 'got some course');

    var sectionCount = aCourse.getSections().count();
    assert(sectionCount > 0, 'sections are returned');
  });
});
