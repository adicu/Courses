describe('Sections', function() {
  before(function() {
    stubMeteor();
  });

  beforeEach(function() {
    this.aSection = Sections.findOne({'courseFull': 'COMSW1004'});
    assert(this.aSection, 'got a section');
  });

  it('should get a parent course', function() {
    var parentCourse = this.aSection.getParentCourse();
    assert(parentCourse, 'got a parent course');
  });

  it('should get meeting times', function() {
    var meetingTimes = this.aSection.getMeetingTimes();
    assert(meetingTimes, 'got meeting times');
    assert.equal(meetingTimes.length, this.aSection.meetsOn[0].length,
      'Number of meeting times is the same as number of days a class meets on');
  });
});
