if (!this.Co) {
  Co = {};
}
// Co is used just as a short namespace for methods
// relating to the Courses application

// Helpers particularly related to Courses
Co.courseHelper = {
  // Converts days of format MTWRF into ints.
  // M => 0, W => 2, etc.
  parseDays: function(days) {
    if (!days) {
      return;
    }
    var daysAbbr = this.getOptions().daysAbbr;
    var parsed = [];
    _.each(days, function(day) {
      if (daysAbbr.indexOf(day) !== -1) {
        parsed.push(daysAbbr.indexOf(day));
      }
    });
    return parsed;
  },

  // Parses times into hours and minutes
  // @param [String] ex. ["0815"]
  // @return [Number, Number] ex. [8, 15]
  parseTimes: function(time) {
    // Ignore times of non length 4
    if (!time || time.length !== 4) {
      return;
    }
    var hour = parseInt(time.slice(0, 2), 10);
    var min = parseInt(time.slice(2), 10);
    return [hour, min];
  },

  getOptions: function() {
    return {
      daysAbbr: "MTWRF",
      specialFields: ['Building', 'EndTime', 'MeetsOn', 'Room', 'StartTime']
    };
  },

  // Converts from sectionFull format to courseFull format
  // ex. COMSS3203 to 20133COMS3203S001
  sectionFulltoCourseFull: function(sectionFull) {
    var subject = sectionFull.slice(5, 9);
    var courseNumber = sectionFull.slice(9, 13);
    var courseType = sectionFull[13];
    return subject + courseType + courseNumber;
  },

  urlFromSectionFull: function(sectionFull, semester) {
    var re = /([a-zA-Z]+)(\d+)([a-zA-Z])(\d+)/g;
    var cu_base = 'http://www.columbia.edu/cu/bulletin/uwb/subj/';

    return sectionFull.replace(re, cu_base + '$1/$3$2-' + semester + '-$4');
  },

  // Return {start: Moment, end: Moment} Object indicating
  // the start and end dates for the current semester
  getCurrentSemesterDates: function() {
    var currentSemester = Number(Session.get('currentSemester'));
    if (!currentSemester) {
      return;
    }
    return Co.constants.semesterDates[currentSemester];
  }
};

Co.toTitleCase = function(str) {
  var titleCaseRegex = /\w\S*/g;
  return str.replace(titleCaseRegex, function(txt) {
    return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
  });
};

// Necessary for anon users package
// Returns the current user object
Co.user = function() {
  if (Meteor.user()) {
    return Meteor.user();
  }

  if (Meteor.userId()) {
    return Meteor.users.findOne(Meteor.userId());
  } else {
    return null;
  }
};
