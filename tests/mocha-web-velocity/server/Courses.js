describe('Courses', function() {
  before(function() {
    stubMeteor();
    return;
    importAllCollections();
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
    var aCourse = Courses.findOne();
    assert(aCourse, 'got some course');

    var sectionCount = aCourse.getSections().count();
    assert(sectionCount, 'sections are returned');
  });
});
