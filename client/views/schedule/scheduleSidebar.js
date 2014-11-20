Template.scheduleSidebar.helpers({
  // Returns credit or credits based on number of points
  formatCreditLabel: function() {
    var points = this.schedule.getTotalPoints();
    if (points === 1) {
      return 'credit';
    } else {
      return 'credits';
    }
  },

  // Closes all accordions
  closeAll: function() {
    $('.scheduleSidebar .accordionItem.active').removeClass('active');
    $('.scheduleSidebar .content.active').removeClass('active');
  },

  // Opens the accordion for the corresponding courseFull
  openAccordion: function(courseFull) {
    Template.scheduleSidebar.closeAll();

    $('.scheduleSidebar .accordionItem-' + courseFull).addClass('active');
    $('.scheduleSidebar .panel-' + courseFull).addClass('active');
  },

  isAccordionOpen: function(courseFull) {
    var accordionItem = $('.scheduleSidebar .panel-' + courseFull);
    return accordionItem.hasClass('active');
  },

  toggleAccordion: function(courseFull) {
    if (Template.scheduleSidebar.isAccordionOpen(courseFull)) {
      return Template.scheduleSidebar.closeAll();
    } else {
      return Template.scheduleSidebar.openAccordion(courseFull);
    }
  },

  getCourses: function() {
    if (!this.schedule) {
      return;
    }
    var cursor = this.schedule.getCourses();
    return cursor;
  }
});

Template.scheduleSidebar.events({
  'click .accordionItem > a': function(e) {
    var item = e.currentTarget;
    var courseFull = $(item).data('coursefull');
    return Template.scheduleSidebar.toggleAccordion(courseFull);
  },
  'click .empty': function(e) {
    var input = $('.search-input');
    if(input){
      input.focus();
    }
  }
});



var SECTIONS_LIMIT = 200;
Template.scheduleSidebarItem.helpers({
  getAbbrevSections: function() {
    return this.course.getSections({
      limit: SECTIONS_LIMIT
    });
  },

  // Checks if the number of sections is greater than some limit
  hasMoreSections: function() {
    return this.course.getSections().count() > SECTIONS_LIMIT;
  },

  getSidebarClasses: function() {
    var classes = [];
    var color = this.schedule.getColor(this.course.course);
    var isInactive = this.schedule.getSectionsForCourse(this.course.course).length === 0;
    if (isInactive) {
      classes.push('gray');
    } else {
      if (color) {
        classes.push(color);
      } else {
        classes.push('true');
      }
    }
    return classes.join(' ');
  }
});

Template.scheduleSidebarItem.events({
  'click input.sectionSelect': function(e) {
    var input = e.target;
    var checked = input.checked;
    if (checked) {
      return this.schedule.addSection(this.section.sectionFull);
    } else {
      return this.schedule.removeSection(this.section.sectionFull);
    }
  },
  'click .deleteCourse': function(e) {
    return this.schedule.removeCourse(this.course.courseFull);
  }
});



Template.scheduleSidebarSection.helpers({
  // TODO: This only displays one set of meeting times
  formatSectionTimes: function() {
    var meetsOn = this.section.meetsOn[0];
    var meetingTime = this.section.getMeetingTimes()[0];
    if (!meetingTime) {
      return "TBA";
    }

    var startTime = meetingTime.start.format('LT');
    var endTime = meetingTime.end.format('LT');
    return meetsOn + " " + startTime + " - " + endTime;
  },

  formatLocation: function() {
    if (!this.section.building[0]) {
      return "Location TBA";
    }
    if (!this.section.room) {
      return this.section.building[0];
    }
    return this.section.building[0] + " " + this.section.room[0];
  },

  formatCallNumber: function() {
    if (!this.section.callNumber) {
      return "Call number TBA";
    }
    else {
      return "Call #" + " " + this.section.callNumber;
    }
  },

  isDisabled: function() {
    if (!this.schedule.isMine()) {
      return 'disabled';
    }
  }
});
