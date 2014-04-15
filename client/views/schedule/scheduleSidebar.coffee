
# Returns credit or credits based on number of points
Template.scheduleSidebar.formatCreditLabel = ->
  points = @schedule.getTotalPoints()
  if points == 1
    return 'credit'
  else
    return 'credits'

# Closes all accordions
Template.scheduleSidebar.closeAll = ->
  $('.scheduleSidebar .accordionItem.active').removeClass 'active'
  $('.scheduleSidebar .content.active').removeClass 'active'

# Opens the accordion for the corresponding courseFull
Template.scheduleSidebar.openAccordion = (courseFull) ->
  Template.scheduleSidebar.closeAll()

  $('.scheduleSidebar .accordionItem-' + courseFull)
    .addClass 'active'

  $('.scheduleSidebar .panel-' + courseFull)
    .addClass 'active'

Template.scheduleSidebar.isAccordionOpen = (courseFull) ->
  accordionItem = $('.scheduleSidebar .panel-' + courseFull)
  return accordionItem.hasClass 'active'

Template.scheduleSidebar.toggleAccordion = (courseFull) ->
  if Template.scheduleSidebar.isAccordionOpen courseFull
    Template.scheduleSidebar.closeAll()
  else
    Template.scheduleSidebar.openAccordion courseFull

Template.scheduleSidebar.getCourses = ->
  cursor = @schedule.getCourses()
  return cursor

Template.scheduleSidebar.events
  'click .accordionItem > a': (e) ->
    item = e.currentTarget
    courseFull = $(item).data('coursefull')

    Template.scheduleSidebar.toggleAccordion courseFull

SECTIONS_LIMIT = 4
Template.scheduleSidebarItem.getAbbrevSections = ->
  return @course.getSections limit: SECTIONS_LIMIT

# Checks if the number of sections is greater than some limit
Template.scheduleSidebarItem.hasMoreSections = ->
  return @course.getSections().count() > SECTIONS_LIMIT

Template.scheduleSidebarItem.events
  'click input.sectionSelect': (e) ->
    input = e.target
    checked = input.checked
    if checked
      @schedule.addSection @section.sectionFull
    else
      @schedule.removeSection @section.sectionFull
  'click .deleteCourse': (e) ->
    @schedule.removeCourse @course.courseFull
