MainPage = require './helpers/MainPage'


describe "Courses homepage", ->
  page = {}

  beforeEach ->
    # $timeout is causing problems
    # TODO: Look into moving to $interval
    # https://github.com/angular/protractor/issues/49
    protractor.getInstance().ignoreSynchronization = true

  it "should open the schedule view", ->
    page = new MainPage()
    url = page.get()

    expect(browser.getCurrentUrl()).toContain('#/schedule')

  it "should search and add the course", ->
    page.searchBox.sendKeys 'COMS1004'
    browser.sleep 1000
    # Should have at least one result
    expect(page.searchResults.count()).toBeGreaterThan(0)

    page.searchResults.get(0).click()
    browser.sleep 500

  it "should show the popover", ->
    expect(page.courseItems.count()).toBe(1)
    page.courseItems.get(0).click()
    browser.sleep 500

    expect(page.popover.count()).toBe(1)
