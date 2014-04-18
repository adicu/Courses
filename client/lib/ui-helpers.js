// Creates helpers usable in all templates

// Convert 0-23 hour time to 12 hour time
UI.registerHelper('toTwelveHours', function(input) {
  if (!input) {
    input = this;
  }
  input = parseInt(input, 10);
  if (input === 0) {
    return 'midnight';
  }
  if (input === 12) {
    return 'noon';
  }
  if (input < 12) {
    return input + 'am';
  }
  if (input > 12) {
    return (input - 12) + 'pm';
  }
});

// Convert 20141 to Spring 2014
UI.registerHelper('readableSemester', function(input) {
  if (!input) {
    input = this;
  }
  var semesters = ['', 'Spring', 'Summer', 'Autumn'];
  var semester = input[input.length - 1];
  return semesters[semester] + ' ' + input.slice(0, 4);
});

// Returns the instructor's last name
UI.registerHelper('instructorLast', function(instructors) {
  if (!instructors) {
    instructors = this;
  }
  var instructor = instructors[0];
  if (!instructor) {
    return 'None';
  }
  var instructorRegex = /([\w ]+),\s+(\w+)\s*(\w*)/;
  var match = instructor.match(instructorRegex);
  if (match && match[1]) {
    return Co.toTitleCase(match[1]);
  }
});

UI.registerHelper('toTitleCase', function(str) {
  if (!str) {
    str = this;
  }
  return Co.toTitleCase(str);
});

UI.registerHelper('debug', function(optionalValue) {
  if (optionalValue) {
    console.log('debug', this, optionalValue);
  } else {
    console.log('debug', this);
  }
});
