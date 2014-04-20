// Returns credit or credits based on number of points
Template.scheduleSidebar.formatCreditLabel = function() {
  var points = this.schedule.getTotalPoints();
  if (points === 1) {
    return 'credit';
  } else {
    return 'credits';
  }
};

// Closes all accordions
Template.scheduleSidebar.closeAll = function() {
  $('.scheduleSidebar .accordionItem.active').removeClass('active');
  $('.scheduleSidebar .content.active').removeClass('active');
};

// Opens the accordion for the corresponding courseFull
Template.scheduleSidebar.openAccordion = function(courseFull) {
  Template.scheduleSidebar.closeAll();

  $('.scheduleSidebar .accordionItem-' + courseFull).addClass('active');
  $('.scheduleSidebar .panel-' + courseFull).addClass('active');
};

Template.scheduleSidebar.isAccordionOpen = function(courseFull) {
  var accordionItem = $('.scheduleSidebar .panel-' + courseFull);
  return accordionItem.hasClass('active');
};

Template.scheduleSidebar.toggleAccordion = function(courseFull) {
  if (Template.scheduleSidebar.isAccordionOpen(courseFull)) {
    return Template.scheduleSidebar.closeAll();
  } else {
    return Template.scheduleSidebar.openAccordion(courseFull);
  }
};

Template.scheduleSidebar.getCourses = function() {
  if (!this.schedule) {
    return;
  }
  var cursor = this.schedule.getCourses();
  return cursor;
};

Template.scheduleSidebar.events({
  'click .accordionItem > a': function(e) {
    var item = e.currentTarget;
    var courseFull = $(item).data('coursefull');
    return Template.scheduleSidebar.toggleAccordion(courseFull);
  }
});



var SECTIONS_LIMIT = 4;
Template.scheduleSidebarItem.getAbbrevSections = function() {
  return this.course.getSections({
    limit: SECTIONS_LIMIT
  });
};

// Checks if the number of sections is greater than some limit
Template.scheduleSidebarItem.hasMoreSections = function() {
  return this.course.getSections().count() > SECTIONS_LIMIT;
};

Template.scheduleSidebarItem.getSidebarClasses = function() {
  var classes = [];
  var color = this.schedule.getColor(this.course.courseFull);
  var isInactive = this.schedule.getSectionsForCourse(this.course.courseFull).length === 0;
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
};

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



// TODO: This only displays one set of meeting times
Template.scheduleSidebarSection.formatSectionTimes = function() {
  var meetsOn = this.section.meetsOn[0];
  var meetingTime = this.section.getMeetingTimes()[0];
  if (!meetingTime) {
    return "TBA";
  }

  var startTime = meetingTime.start.format('LT');
  var endTime = meetingTime.end.format('LT');
  return meetsOn + " " + startTime + " - " + endTime;
};

Template.scheduleSidebarSection.isDisabled = function() {
  if (!this.schedule.isMine()) {
    return 'disabled';
  }
};
