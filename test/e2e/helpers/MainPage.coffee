config = require '../../global.conf.coffee'
By = protractor.By


class MainPage
  constructor: ->
    @searchBox = element By.model 'searchQuery'
    @searchResults = element.all By.repeater 'result in searchResults'
    @courseItems = element.all By.className 'courseItem'

    @popover = element.all By.className 'popover'

  get: ->
    browser.get config.LOCAL_URL
    browser.getCurrentUrl()

module.exports = MainPage
