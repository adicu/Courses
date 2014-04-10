The following are notes on the functionality of Courses for which
the README doesn't seem like the correct place for:

## Data Model
`Schedule` has multiple `Course`s, which have multiple `Section`s which have
multiple `Subsection`s.

A `Schedule` represents a given person's schedule (ex. with 5 classes).
A `Course` represents a given course, including all the times it was
offered (ex. all the semesters of COMS1004).
A `Section` represents a single semester of a course, with an associated
instructor. (ex. Jae's AP class in Fall 2014).
A `Subsection` represents a single time when a student will continuously
sit in class. (ex. M 1-4 of a MW 1-4 class).

## Adding a Course
Searching for a course takes place in the `searchArea` directive which
is put in the page in `public/partials/schedule.html` which loads all of
the directives that are used in the schedule view page.

> Note that directive code is in `src/js/directives/` and the corresponding
> html(template) code is in `public/partials/directives/`.

Clicking on a result will activate the `ng-click` attribute of the result,
which will call `courseSelect` with the result. The code for courseSelect
is defined in `searchArea.coffee`. This will then call the `onselect`
method of the `searchArea` scope. This, as can be seen in the `scope:`
property of `searchArea.coffee`, is set to `onselect: &` which means that
`onselect` is a reference inherited from the parent scope.

Open up `schedule.html` to see where the parent scope is defined. As the
file shows, `onselect=courseSelect(course)` which means that onselect
will activate the courseSelect method on the schedule scope.

The code for the schedule scope is defined in `scheduleCtrl.coffee`.
Here, the controller will call `Course.fetchByCourseFull()` and then
call `$scope.schedule.addCourse` (the current schedule) to add the
course that was gotten from the fetch to the current schedule.

`Schedule` will then update its arrays `@courses` and `@sectionsByDay`
and then angular will detect this. See `weekView.html`, particularly
the `day in sectionsByDay()` which will return an array of sections
for a given day (for example, all the sections on Monday.)

Then, those sections are iterated over and will be displayed in their
respective columns. This is done by using a computed CSS property on
Subsections (ex. M 2-3pm for a MW 2-3pm class). This CSS property is
computed in the `Subsection` constructor and also when the `Schedule`
adds new courses (to detect overlaps).

## Schedule logic (aka why is @courses not a function?)
Angular seemed to have problems when `@courses` and `@sectionsByDay`
were computed on the fly, so they were changed into arrays that
are automatically recomputed by the `update()` method that is called
each time the schedule is mutated in any way. This also means that
only the methods of `Schedule` may mutate itself.
