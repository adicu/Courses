MainPage = require './helpers/MainPage'


describe "Courses homepage", ->
  page = {}

  beforeEach ->
    # $timeout is causing problems
    # TODO: Look into moving to $interval
    # https://github.com/angular/protractor/issues/49
    protractor.getInstance().ignoreSynchronization = true

    page = new MainPage()
    url = page.get()

  it "should open the schedule view", ->
    expect(browser.getCurrentUrl()).toContain('#/schedule')

  it "should search and add the course", ->
    page.searchBox.sendKeys 'COMS1004'
    browser.sleep 1000
    # Should have at least one result
    expect(page.firstResult.isDisplayed()).toBe(true)

    page.firstResult.click()
    browser.sleep 500

    page.courseItems.then (courseItems) ->
      expect(courseItems.length).toBe(1)

  it "should show the popover", ->
    page.courseItems.then (courseItems) ->
      courseItems[0].click()
    browser.sleep 500

    page.popover.then (popover) ->
      expect(popover.length).toBe(1)
