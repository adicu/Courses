# Creates helpers usable in all templates

# Convert 0-23 hour time to 12 hour time
UI.registerHelper 'toTwelveHours', (input = this) ->
  input = Number input
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

# Returns the instructor's last name
UI.registerHelper 'instructorLast', (instructors = this) ->
  instructor = instructors[0]
  if not instructor
    return 'None'
  instructorRegex = /([\w ]+),\s+(\w+)\s*(\w*)/
  match = instructor.match instructorRegex
  if match and match[1]
    return Co.toTitleCase match[1]

UI.registerHelper 'toTitleCase', (str = this) ->
  return Co.toTitleCase str

UI.registerHelper 'debug', (optionalValue) ->
  if optionalValue
    console.log('debug', this, optionalValue);
  else
    console.log('debug', this);
