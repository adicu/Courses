Schedules = new Meteor.Collection('schedules', {
  schema: new SimpleSchema({
    addedCourses: {
      type: [Object],
      optional: true
    },
    'addedCourses.$.course': {
      type: String,
      label: 'CourseFull reference'
    },
    'addedCourses.$.color': {
      type: String,
      label: 'Color associated with course'
    },
    addedSections: {
      type: [Object],
      optional: true
    },
    'addedSections.$.section': {
      type: String,
      label: 'SectionFull reference'
    },
    semester: {
      // Careful, this needs to be parsed to a number
      type: Number
    },
    createdAt: CollectionsShared.createdAt,
    updatedAt: CollectionsShared.updatedAt,
    owner: CollectionsShared.owner
  })
});

Schedules.allow({
  insert: function(userId, doc) {
    return userId && doc.owner === userId;
  },
  update: function(userId, doc, fields, modifier) {
    return doc.owner === userId;
  },
  remove: function(userId, doc) {
    return doc.owner === userId;
  },
  fetch: ['owner']
});

Schedules.helpers({
  addCourse: function(courseFull, callback) {
    var that = this;
    Meteor.subscribe('courses', courseFull, function() {
      var course = Courses.findOne({
        courseFull: courseFull
      });

      if (!course) {
        if (callback) {
          callback(new Error('This course does not exist'));
        }
        return;
      }

      Schedules.update(that._id, {
        $push: {
          addedCourses: {
            course: courseFull,
            color: that.randomUniqueColor()
          }
        }
      }, null, callback); // No options

      var sections = Sections.find({
        courseFull: courseFull,
        term: Session.get('currentSemester')
      }).fetch();
      if (sections.length === 1) {
        return that.addSection(sections[0].sectionFull);
      }
    });
  },

  addSection: function(sectionFull) {
    return Schedules.update(this._id, {
      $push: {
        addedSections: {
          section: sectionFull
        }
      }
    });
  },

  // Removes course and all related sections from the schedule
  removeCourse: function(courseFull) {
    Schedules.update(this._id, {
      $pull: {
        addedCourses: {
          course: courseFull
        }
      }
    });

    var sectionFulls = _.pluck(this.getSectionsForCourse(courseFull), 'sectionFull');
    if (!sectionFulls) {
      return;
    }
    sectionFulls = _.map(sectionFulls, function(sectionFull) {
      return {
        section: sectionFull
      };
    });
    return Schedules.update(this._id, {
      $pullAll: {
        addedSections: sectionFulls
      }
    });
  },

  removeSection: function(sectionFull) {
    return Schedules.update(this._id, {
      $pull: {
        addedSections: {
          section: sectionFull
        }
      }
    });
  },

  getCourses: function() {
    var courses = this.getCourseFulls();
    return Courses.find({
      courseFull: {
        $in: courses
      }
    }, {
      sort: ['course']
    });
  },

  getSections: function() {
    var sections = this.getSectionFulls();
    return Sections.find({
      sectionFull: {
        $in: sections
      },
      term: Session.get('currentSemester')
    });
  },

  // @return [Section] The sections that are
  // associated with a given courseFull
  getSectionsForCourse: function(courseFull) {
    var sections = this.getSections().fetch();
    return _.filter(sections, function(section) {
      return section.courseFull === courseFull;
    });
  },

  isSelected: function(sectionFull) {
    return _.contains(this.getSectionFulls(), sectionFull);
  },

  isMine: function() {
    var userID = '';
    if (Co.user()) {
      userID = Co.user()._id;
    }

    return this.owner === userID;
  },

  getCourseFulls: function() {
    return _.pluck(this.addedCourses, 'course');
  },

  getSectionFulls: function() {
    return _.pluck(this.addedSections, 'section');
  },

  getTotalPoints: function() {
    var totalPoints = 0;
    var sectionFulls = this.getSectionFulls();
    var selectedCourseFulls = _.map(sectionFulls, function(item) {
      return Co.courseHelper.sectionFulltoCourseFull(item);
    });
    selectedCourseFulls = _.uniq(selectedCourseFulls);
    _.each(this.getCourses().fetch(), function(course) {
      if (_.contains(selectedCourseFulls, course.courseFull)) {
        totalPoints += course.numFixedUnits / 10;
      }
    });
    return totalPoints;
  },

  // @return String - a color which is attempted to be unique
  randomUniqueColor: function() {
    var usedColors = _.pluck(this.addedCourses, 'color');
    var unusedColors = _.difference(Co.courseHelper.colors, usedColors);
    if (!unusedColors) {
      // All colors have been used, give up on uniquness
      unusedColors = Co.courseHelper.colors;
    }
    return _.sample(unusedColors);
  },

  // @return [String] the color associated with a given courseFull
  getColor: function(courseFull) {
    var addedCourse = _.find(this.addedCourses, function(course) {
      return course.course === courseFull;
    });
    if (addedCourse) {
      return addedCourse.color;
    }
  },

  // Converts all included sections to FullCalendar Event objects
  // @return [Event]
  toFCEvents: function() {
    var that = this;
    var sections = this.getSections().fetch();
    var events = _.map(sections, function(section){
      return section.toFCEvents();
    });
    events = _.flatten(events);

    // Add color to events
    _.each(events, function(evt){
      var color = that.getColor(evt.courseFull);

      if (color) {
        evt.className = color;
      }
    });

    return events;
  }
});
