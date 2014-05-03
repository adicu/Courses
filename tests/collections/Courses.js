var assert = require('assert');

describe('Courses', function() {
  it('should full text search', function(done, server, c1) {
    var results = c1.evalSync(function() {
      Courses.search('COMS');
      Deps.autorun(function() {
        var results = Session.get('coursesSearchResults');
        emit('return', results);
      });
    });

    assert(results, 'No results returned.');
    done();
  });

  it('should get associated sections', function(done, server) {
    runFixtures(server, 'Courses');
    runFixtures(server, 'Sections');

    var sections = server.evalSync(function() {
      Session = null;
      var sections = Courses.findOne().getSections().count();
      emit('return', sections);
    });

    assert(sections, 'No associated sections');
    done();
  });
});
