ScheduleViewController = RouteController.extend({
  onBeforeAction: function() {
    Session.set('coursesSearchResults', []);
    if (!Meteor.userId()) {
      Meteor.loginVisitor();
    }
  },

  onStop: function() {
    // Clear search results when leaving page
    Session.set('coursesSearchResults', []);
  },

  onData: function() {
    var data = this.data();
    if (data && data.schedule) {
      var courseFulls = data.schedule.getCourseFulls();
      Meteor.subscribe('courses', courseFulls);
    }
  },

  waitOn: function() {
    return [
      Meteor.subscribe('schedules')
    ];
  },

  data: function() {
    var data = {
      searchResults: Session.get('coursesSearchResults'),
      semesters: Co.constants.semesters
    };

    // Set semesters to the first one by default
    if (data.semesters && data.semesters.length >= 1) {
      Session.setDefault('currentSemester', String(data.semesters[0]));
    }

    if (Co.user()) {
      data.schedule = Schedules.findOne({
        owner: Co.user()._id,
        semester: Number(Session.get('currentSemester'))
      });
    }
    return data;
  }
});
