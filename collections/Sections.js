Sections = new Meteor.Collection('sections');

var schema = new SimpleSchema({
  courseFull: {
    type: String,
    label: 'ex. COMSS3203',
    index: 1
  },
  sectionFull: {
    type: String,
    label: 'ex. 20133COMS3203S001',
    index: 1,
    unique: true
  },
  callNumber: {
    type: Number
  },
  meetsOn: {
    type: [String]
  },
  building: {
    type: [String]
  },
  startTime: {
    type: [String]
  },
  endTime: {
    type: [String]
  },
  term: {
    type: String
  },
  instructors: {
    type: [String]
  },
  numEnrolled: {
    type: Number
  },
  room: {
    type: [String]
  },
  createdAt: CollectionsShared.createdAt
});
Sections.attachSchema(schema);

Sections.helpers({
  // Finds the Courses object associated with this Section
  getParentCourse: function() {
    return Courses.findOne({
      courseFull: this.courseFull
    });
  },

  // Parses the time fields
  // @return [DateRange] - start, end
  // See moment-range package for info on DateRange
  // An array of start and end times based on the next Monday
  // after the start of classes for the current semester
  // Each meeting of class will generate one - MW => 2 starts and ends
  getMeetingTimes: function() {
    // Next Monday after the current start date
    var baseDate = Co.courseHelper.getCurrentSemesterDates().start.day(1);
    var meetingTimes = [];

    for (var i = 0; i < this.meetsOn.length; i++) {
      var parsedDays = Co.courseHelper.parseDays(this.meetsOn[i]);
      var parsedStart = Co.courseHelper.parseTimes(this.startTime[i]);
      var parsedEnd = Co.courseHelper.parseTimes(this.endTime[i]);
      // A field is missing - possible error condition
      if (!(parsedDays && parsedStart && parsedEnd)) {
        continue;
      }
      // ex. iterate over [M, W] (actually [0, 2])
      _.each(parsedDays, function(day) {
        var newStart = moment(baseDate);
        var newEnd = moment(baseDate);
        // Set the day of the week, increment by 1 to account for
        // Sunday being 0 instead of Monday being 0
        newStart.day(day + 1);
        newEnd.day(day + 1);

        newStart.hour(parsedStart[0]).minute(parsedStart[1]);
        newEnd.hour(parsedEnd[0]).minute(parsedEnd[1]);

        meetingTimes.push(moment().range(newStart, newEnd));
      });
    }
    return meetingTimes;
  },

  // Converts this section to FullCalendar Event objects
  // @return [Event]
  toFCEvents: function() {
    var events = [];
    var parentCourse = this.getParentCourse();
    if (!this.getParentCourse)
      return;
    var location = "";
    console.log(this);
    if (!this.building[0]) {
      location = "Location TBA";
    } else if (!this.room[0]) {
      location = this.building[0];
    } else {
      location = this.building[0] + " " + this.room[0];
    }
    var title = this.courseFull + ' ' + location;
    var baseEvent = {
      id: this.sectionFull,
      title: title,
      courseFull: this.courseFull
    };
    _.each(this.getMeetingTimes(), function(range) {
      var newEvent = _.extend({}, baseEvent, {
        start: range.start,
        end: range.end,
        range: range
      });
      events.push(newEvent);
    });

    return events;
  }
});
