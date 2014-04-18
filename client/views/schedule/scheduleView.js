var SEARCH_TIMEOUT = 750;

Template.scheduleSearchArea.semesterClasses = function() {
  var selectedSemester = String(this);
  var currentSemester = Session.get('currentSemester');
  if (selectedSemester === currentSemester) {
    return ['active'];
  }
};

// Clears the search bar and search results
var resetSearch = function() {
  var searchInput = $('#searchInput');
  searchInput.val('');
  Session.set('coursesSearchResults', []);
};

var createOrGetSchedule = function() {
  var semester = Session.get('currentSemester');
  var user = Co.user();

  if (user) {
    var schedule = getSchedule();
    if (!schedule) {
      var newSchedule = Schedules.insert({
        semester: parseInt(semester, 10)
      });
      schedule = Schedules.findOne(newSchedule);
    }
    return schedule;
  } else {
    return handleError(new Error('No user!'));
  }
};

var getSchedule = function() {
  var semester = Session.get('currentSemester');
  var user = Co.user();

  if (user) {
    return Schedules.findOne({
      owner: user._id,
      semester: parseInt(semester, 10)
    });
  }
};

var searchTimeout;
Template.scheduleSearchArea.events({
  'click .semesterToggle': function(e) {
    var selectedSemester = String(this);
    Session.set('currentSemester', String(selectedSemester));
  },
  'click .courseResultItem': function(e) {
    var that = this;
    var schedule = createOrGetSchedule();
    schedule.addCourse(this.CourseFull, function(err) {
      if (err) {
        handleError(err);
      }
      Template.scheduleSidebar.openAccordion(that.CourseFull);
    });
    resetSearch();
  },
  'input input': function(e) {
    var input = e.target;
    var query = input.value;

    // Run search after interval if not queued already
    if (searchTimeout) {
      Meteor.clearTimeout(searchTimeout);
    }

    searchTimeout = Meteor.setTimeout(function() {
      if (query) {
        Courses.search(query);
      } else {
        resetSearch();
      }
      searchTimeout = null;
    }, SEARCH_TIMEOUT);
  }
});



// Runs automatically when template is rendered
var scheduleComputation;
Template.scheduleWeekView.rendered = function() {
  var startDate = Co.courseHelper.getCurrentSemesterDates().start;
  // Will be populated by the autorun whenever
  // schedule or sections changes
  var fcEvents = [];
  $('#calendar').fullCalendar({
    events: function(start, end, callback) {
      callback(fcEvents);
    },
    eventClick: function(fcEvent, e, view) {
      Template.scheduleSidebar.toggleAccordion(fcEvent.courseFull);
    },
    weekends: false,
    defaultView: 'agendaWeek',    // Just show week view
    header: false,                // Disable default headers
    allDaySlot: false,            // Disable all day header
    allDayDefault: false,         // Make events default not all day
    columnFormat: {
      week: 'dddd'                // Don't show the specific day
    },
    minTime: 7,                   // Start at 7am
    height: 100000,               // Force full view
    year: startDate.year(),
    month: startDate.month(),
    // Finds the next Monday after the start and
    // returns the date of the month
    date: moment(startDate).day(1).date()
  });

  scheduleComputation = Deps.autorun(function() {
    var schedule = getSchedule();
    if (schedule) {
      fcEvents = schedule.toFCEvents();
      $('#calendar').fullCalendar('refetchEvents');
    } else {
      fcEvents = [];
      $('#calendar').fullCalendar('refetchEvents');
    }
  });
};

Template.scheduleWeekView.destroyed = function() {
  if (scheduleComputation) {
    scheduleComputation.stop();
  }
};
