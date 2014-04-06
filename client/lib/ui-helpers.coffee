# Creates helpers usable in all templates

# Convert 0-23 hour time to 12 hour time
UI.registerHelper 'toTwelveHours', (input = this) ->
  if input == 0
    return 'midnight'
  if input == 12
    return 'noon'
  if input < 12
    return input + 'am'
  if input > 12
    return (input - 12) + 'pm'

# Convert 20141 to Spring 2014
UI.registerHelper 'readableSemester', (input = this) ->
  semesters = ['', 'Spring', 'Summer', 'Autumn']
  semester = input[input.length - 1]

  semesters[semester] + ' ' + input[0..3]

# Converts from int[0-6] to day
UI.registerHelper 'readableDay', (input = this) ->
  days =
    0: 'Monday',
    1: 'Tuesday',
    2: 'Wednesday',
    3: 'Thursday',
    4: 'Friday',
    5: 'Saturday',
    6: 'Sunday'
  days[input]

# Converts 24 time 13:10:30 to 1:10pm
UI.registerHelper 'readableTime', (time = this) ->
  time_re = /(\d+):(\d+):(\d+)/
  d = time.match time_re
  if d == null
    return time
  h = d[1]
  m = d[2]
  s = d[3]
  ampm = 'am'
  if h = 12
    ampm = 'pm'
  else if h > 12
    h = h - 12
    ampm = 'pm'

  time = h + ':' + m + ' ' +  ampm

UI.registerHelper 'debug', (optionalValue) ->
  if optionalValue
    console.log('debug', this, optionalValue);
  else
    console.log('debug', this);
