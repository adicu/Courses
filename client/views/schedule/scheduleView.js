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

// Gets the schedule from the Router param
// Generally should not use
var dirtyGetSchedule = function() {
  var currentRouter = Router.current();
  if (currentRouter.params._id) {
    return Schedules.findOne(currentRouter.params._id);
  }
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



// Runs automatically when template is rendered
Template.scheduleSearchArea.rendered = function() {
  var results;

  var currentIndex = function() {
    /**
     * Return the index of the selected search result in the list of course
     * search results, or 0 if none are selected. It has the `selected` class.
     */

    var selectedResult = $('.courseResultItem.selected');
    if (!selectedResult) {
      return 0;
    }

    var selectedCourseFull = selectedResult.data('course-full');
    var selectedIndex = results.map(function(r) {return r.CourseFull; })
                               .indexOf(selectedCourseFull);
    if (selectedIndex === -1) {
      return 0;
    }
    return selectedIndex;
  };

  var selectResultAtIndex = function(index) {
    /**
     * Deselect the currently selected search result, and select the result at
     * `index`.
     */
    $('.courseResultItem.selected').removeClass('selected');
    courseFull = results[index].CourseFull;
    $('.courseResultItem[data-course-full="' + courseFull +'"]').addClass('selected');
  };

  var up = function() {
    /**
     * Select the search result above, if there is one.
     */
    var idx = currentIndex();
    if (idx > 0) {
      selectResultAtIndex(idx - 1);
    }
  };

  var down = function() {
    /**
     * Select the search result below, if there is one.
     */
    var idx = currentIndex();
    if (idx + 1 < results.length){
      selectResultAtIndex(idx + 1);
    }
  };

  var keydownHandler = function(e) {
    /**
     * Handle keypresses while the search results are displayed like so:
     *  - tab / shift+tab cycle up and down the results list
     *  - up / down do the same
     *  - enter adds the selected class
     *  - esc clears the search
     */
    switch(e.which) {
      case 9: //tab, shift+tab
      if (e.shiftKey) {
        up();
      } else {
        down();
      }
      break;

      case 13: //enter
      $('.courseResultItem.selected').click();
      break;

      case 27: //escape
      resetSearch();
      break;

      case 38: //up
      up();
      break;

      case 40: //down
      down();
      break;

      default:
      return;
    }
    e.preventDefault();
  };

  var clickHandler = function(e) {
    /**
     * Clicking back into the search box to edit a query should not clear it
     */
    e.stopPropagation();
  };

  Deps.autorun(function() {
    results = Session.get('coursesSearchResults');

    if (results.length > 0) {
      // The results exist, but the DOM elements don't exist yet. Wait until
      // they do, and then select the first one.
      var checkExist = setInterval(function() {
         if ($('.courseResultItem').length) {
            clearInterval(checkExist);
            selectResultAtIndex(0);
         }
      }, 50);

      // bind keydown and click outside to reset, or press ESC (which defocuses
      // or 'blur's the input)
      $(document).bind('keydown', keydownHandler);
      $(document).bind('click', resetSearch);
      $('.search-input').bind('click', clickHandler);

    } else {
      // The search results are not being shown, unbind keydown, click, and blur
      $(document).unbind('keydown', keydownHandler);
      $(document).unbind('click', resetSearch);
      $('.search-input').unbind('click', clickHandler);
    }
  });
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
    e.stopPropagation();
    var that = this;
    var schedule = createOrGetSchedule.call(this);
        schedule.addCourse(this.result.Course, function(err) {
      if (err) {
        handleError(err);
      }
      $('.scheduleSidebar').trigger('toggleAccordion', that.result.CourseFull);
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

    // IronRouterProgress.start();
    searchTimeout = Meteor.setTimeout(function() {
      if (query) {
        //Pass termination of the progress bar to be called when search finishes
        Courses.search(query, function(){
          // IronRouterProgress.done();
        });
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
    var schedule = dirtyGetSchedule();

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
