var SEARCH_TIMEOUT = 750;

// Shows search if there either is no current schedule or
// the the current schedule is editable.
Template.scheduleView.shouldShowSearch = function() {
  if (!this.schedule) {
    return true;
  } else if (this.schedule.isMine()) {
    return true;
  } else {
    return false;
  }
};



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

  if (Co.user()) {
    var schedule = this.schedule;
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

var searchTimeout;
Template.scheduleSearchArea.events({
  'click .semesterToggle': function(e) {
    var selectedSemester = String(this);
    Session.set('currentSemester', String(selectedSemester));

    // Clear the _id parameter of the URL to tell the controller
    // to look for a different schedule
    Router.go('scheduleView');
  },
  'click .courseResultItem': function(e) {
    var that = this;
    var schedule = createOrGetSchedule.call(this);
    schedule.addCourse(this.result.CourseFull, function(err) {
      if (err) {
        handleError(err);
      }
      Template.scheduleSidebar.openAccordion(that.result.CourseFull);
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
var scheduleComputation, startDateComputation;
Template.scheduleWeekView.rendered = function() {
  var that = this;
  // Will be populated by the autorun whenever
  // schedule or sections changes
  var fcEvents = [];
  var fcOptions = {
    events: function(start, end, timezone, callback) {
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
    minTime: moment.duration(7, 'hours'), // Start at 7am
    height: 100000                // Force full view
  };
  $('#calendar').fullCalendar(fcOptions);

  // Automatically runs whenever the start date changes
  // (ex. When the semester changes)
  startDateComputation = Deps.autorun(function() {
    var startDate = Co.courseHelper.getCurrentSemesterDates().start;

    $('#calendar').fullCalendar(
      'gotoDate',
      // The Monday before the startdate
      moment(startDate).day(1)
    );
  });

  // Automatically runs whenever the schedule object changes
  scheduleComputation = Deps.autorun(function() {
    if (!that.data.schedule)
      return;
    // Necessary to properly establish dependency
    var schedule = Schedules.findOne(that.data.schedule._id);
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
  if (scheduleComputation)
    scheduleComputation.stop();

  if (startDateComputation)
    startDateComputation.stop();
};
