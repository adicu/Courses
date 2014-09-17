// View iron-router for documentation on this

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
      // The user has a current schedule
      var courseFulls = data.schedule.getCourseFulls();
      Meteor.subscribe('courses', courseFulls);

      if (data.schedule._id !== this.params._id) {
        // Change to current schedule URL
        Co.smartRedirect.call(
          this,
          'scheduleView',
          {_id: data.schedule._id}
        );
      }
    } else if (this.params._id && (!data || !data.schedule)) {
      // ID parameter, but no matching schedule exists
      Co.smartRedirect.call(this, 'scheduleView');
    }
  },

  unload: function() {
    Session.set('routerPrevPath', this.path);
  },

  waitOn: function() {
    var subscriptions = [];

    if (this.params._id) {
      subscriptions.push(Meteor.subscribe('schedule', this.params._id));
    }
    subscriptions.push(Meteor.subscribe('mySchedules'));
    return subscriptions;
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

    if (this.params._id) {
      check(this.params._id, String);
      data.schedule = Schedules.findOne(this.params._id);
    } else if (Co.user()) {
      data.schedule = Schedules.findOne({
        owner: Co.user()._id,
        semester: Number(Session.get('currentSemester'))
      });
    }

    return data;
  }
});
