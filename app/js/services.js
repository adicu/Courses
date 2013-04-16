// Generated by CoffeeScript 1.3.3
'use strict';

var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

angular.module('Courses.services', []).factory('Course', function($http, $q, ejsResource, Section) {
  var Course;
  return Course = (function() {

    Course.api_url = 'http://data.adicu.com/courses/v2/';

    Course.api_token = '515abdcf27200000029ca515';

    Course.ejs = ejsResource('http://db.data.adicu.com:9200');

    window.ej = Course.ejs;

    Course.request = ejs.Request().indices('jdbc');

    function Course(id, semester, ejs) {
      this.id = id;
      this.semester = semester;
      this.ejs = ejs != null ? ejs : null;
      this.id = this.id;
      this.semester = this.semester;
      if (this.ejs !== null) {
        this.title = this.ejs.coursetitle;
        this.description = this.ejs.description;
        this.points = this.ejs.numfixedunits / 10.0;
      }
    }

    Course.prototype.fillData = function() {
      var d, ptr;
      ptr = this;
      d = $q.defer();
      $http({
        method: 'JSONP',
        url: Course.api_url + 'courses',
        params: {
          course: this.id,
          term: this.semester,
          jsonp: 'JSON_CALLBACK',
          api_token: Course.api_token
        }
      }).success(function(datarecv, status, headers, config) {
        if (!datarecv.data) {
          return null;
        }
        ptr.data = Course.convertAPItoEJS(datarecv.data[0]);
        ptr.title = ptr.data.coursetitle;
        ptr.description = ptr.data.description;
        if (ptr.description === null) {
          ptr.description = "No description given";
        }
        ptr.points = ptr.data.numfixedunits / 10.0;
        return d.resolve(true);
      }).error(function(data, status) {
        return d.resolve(false);
      });
      return d.promise;
    };

    Course.CUITCaseToUnderscore = function(cuitcase) {
      cuitcase = cuitcase.charAt(0).toLowerCase() + cuitcase.slice(1);
      return cuitcase.replace(/([A-Z])/g, function($1) {
        return "" + $1.toLowerCase();
      });
    };

    Course.convertAPItoEJS = function(coursedata) {
      var k, v;
      for (k in coursedata) {
        v = coursedata[k];
        coursedata[Course.CUITCaseToUnderscore(k)] = v;
      }
      return coursedata;
    };

    Course.prototype.getSections = function() {
      var d, promises, ptr, s, sec, _i, _j, _len, _len1, _ref, _ref1;
      if (this.sections && this.sections.length >= 1) {
        return;
      }
      ptr = this;
      d = $q.defer();
      ptr.sections = [];
      _ref = ptr.data.sections;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sec = _ref[_i];
        if (sec.Term === ptr.semester) {
          s = new Section(sec.CallNumber, ptr.semester, sec, ptr);
          ptr.sections.push(s);
        }
      }
      promises = [];
      _ref1 = ptr.sections;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        sec = _ref1[_j];
        promises.push(sec.fillData());
      }
      $q.all(promises).then(function() {
        ptr.sections = ptr.sections.filter(function(el) {
          var subsec, _k, _len2, _ref2;
          _ref2 = el.subsections;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            subsec = _ref2[_k];
            if (subsec.length > 0) {
              return true;
            }
          }
          return false;
        });
        return d.resolve(true);
      });
      return d.promise;
    };

    Course.search = function(query, semester, length, page) {
      return Course.request.query(ejs.BoolQuery().must(ejs.WildcardQuery('term', '*' + semester + '*')).should(ejs.QueryStringQuery(query + '*').fields(['coursetitle^3', 'course^4', 'description', 'coursesubtitle', 'instructor^2'])).should(ejs.QueryStringQuery('*' + query + '*').fields(['course', 'coursefull'])).minimumNumberShouldMatch(1)).doSearch().then(function(data) {
        var hit, hits, _i, _len, _results;
        if (!(data.hits != null) && (data.hits.hits != null)) {
          return;
        }
        hits = data.hits.hits;
        _results = [];
        for (_i = 0, _len = hits.length; _i < _len; _i++) {
          hit = hits[_i];
          _results.push(new Course(hit._source.course, semester, hit._source));
        }
        return _results;
      });
    };

    return Course;

  })();
}).factory('Section', function($http, $q) {
  var Section;
  return Section = (function() {

    Section.api_url = 'http://data.adicu.com/courses/v2/';

    Section.api_token = '515abdcf27200000029ca515';

    function Section(callnum, semester, data, parent) {
      this.semester = semester;
      this.data = data != null ? data : null;
      this.parent = parent != null ? parent : null;
      this.call = callnum;
      this.semester = this.semester;
      this.data = this.data;
      this.parent = this.parent;
    }

    Section.prototype.fillParent = function(Course) {
      var d;
      d = $q.defer();
      if (this.parent === null) {
        this.parent = new Course(this.data.Course, this.semester);
        this.parent.fillData().then(function(status) {
          return d.resolve(true);
        });
      } else {
        d.resolve(true);
      }
      return d.promise;
    };

    Section.prototype.getData = function() {
      var d, ptr;
      if (this.subsections && this.subsections.length >= 1) {
        return;
      }
      ptr = this;
      d = $q.defer();
      if (!ptr.data) {
        $http({
          method: 'JSONP',
          url: Section.api_url + 'sections',
          params: {
            call_number: this.call,
            term: this.semester,
            jsonp: 'JSON_CALLBACK',
            api_token: Section.api_token
          }
        }).success(function(data, status, headers, config) {
          if (!data.data) {
            return d.resolve(false);
          }
          ptr.data = data.data[0];
          return d.resolve(true);
        }).error(function(data, status) {
          return d.reject(false);
        });
      } else {
        d.resolve(true);
      }
      return d.promise;
    };

    Section.prototype.fillData = function(Course) {
      var d, ptr;
      if (Course == null) {
        Course = null;
      }
      if (this.subsections && this.subsections.length >= 1) {
        return;
      }
      ptr = this;
      d = $q.defer();
      ptr.getData().then(function() {
        ptr.call = ptr.call;
        ptr.id = ptr.data.Course;
        return ptr.fillParent(Course).then(function() {
          var i, _i;
          ptr.subsections = [];
          for (i = _i = 0; _i <= 6; i = ++_i) {
            ptr.subsections[i] = [];
          }
          ptr.parseDayAndTime();
          ptr.urlFromSectionFull(ptr.data.SectionFull);
          return d.resolve(true);
        });
      });
      return d.promise;
    };

    Section.prototype.urlFromSectionFull = function(sectionfull) {
      var cu_base, re;
      re = /([a-zA-Z]+)(\d+)([a-zA-Z])(\d+)/g;
      cu_base = 'http://www.columbia.edu/cu/bulletin/uwb/subj/';
      this.url = sectionfull.replace(re, cu_base + '$1/$3$2-' + this.data.Term + '-$4');
      return this.sectionNum = sectionfull.replace(re, '$4');
    };

    Section.prototype.parseDayAndTime = function() {
      var day, end, i, start, _i, _results;
      _results = [];
      for (i = _i = 1; _i <= 2; i = ++_i) {
        if (!this.data['MeetsOn' + i]) {
          continue;
        }
        _results.push((function() {
          var _j, _len, _ref, _results1;
          _ref = Section.parseDays(this.data['MeetsOn' + i]);
          _results1 = [];
          for (_j = 0, _len = _ref.length; _j < _len; _j++) {
            day = _ref[_j];
            start = Section.parseTime(this.data['StartTime' + i]);
            end = Section.parseTime(this.data['EndTime' + i]);
            if (day >= 0 && day <= 6) {
              _results1.push(this.subsections[day].push({
                id: this.id,
                title: this.parent.title,
                instructor: this.data.Instructor1Name,
                parent: this,
                day: day,
                start: start,
                end: end,
                css: Section.computeCss(start, end)
              }));
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Section.prototype.overlapCheck = function(calendar, dayNum) {
      var count, day, days, entry, subsection, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
      days = dayNum || [0, 1, 2, 3, 4, 5, 6];
      count = 0;
      for (_i = 0, _len = days.length; _i < _len; _i++) {
        day = days[_i];
        _ref = this.subsections[day];
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          subsection = _ref[_j];
          _ref1 = calendar[day];
          for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
            entry = _ref1[_k];
            if (subsection.start <= entry.end && subsection.end >= entry.start) {
              return true;
            }
          }
        }
      }
      return false;
    };

    Section.parseDays = function(days) {
      var day, daysAbbr, _i, _len, _results;
      if (!(days != null)) {
        return;
      }
      daysAbbr = Section.options.daysAbbr;
      _results = [];
      for (_i = 0, _len = days.length; _i < _len; _i++) {
        day = days[_i];
        if (daysAbbr.indexOf(day !== -1)) {
          _results.push(daysAbbr.indexOf(day));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    Section.parseTime = function(time) {
      var hour, intTime, minute;
      if (!(time != null)) {
        return;
      }
      hour = parseInt(time.slice(0, 2));
      minute = parseInt(time.slice(3, 5));
      return intTime = hour + minute / 60.0;
    };

    Section.computeCss = function(start, end) {
      var height_pixels, top_pixels;
      if (!(start != null)) {
        return;
      }
      top_pixels = Math.abs(start - Section.options.start_hour) * Section.options.pixels_per_hour + Section.options.top_padding;
      height_pixels = Math.abs(end - start) * Section.options.pixels_per_hour;
      return {
        "top": top_pixels,
        "height": height_pixels
      };
    };

    Section.options = {
      pixels_per_hour: 38,
      start_hour: 8,
      top_padding: 38,
      daysAbbr: "MTWRF"
    };

    return Section;

  })();
}).factory('Calendar', function($http, $q, Course, Section, $location) {
  var Calendar;
  return Calendar = (function() {

    function Calendar() {
      this.showAllSections = __bind(this.showAllSections, this);

      var i, _i;
      this.courses = {};
      this.sections = {};
      this.courseCalendar = [];
      for (i = _i = 0; _i <= 6; i = ++_i) {
        this.courseCalendar[i] = [];
      }
    }

    Calendar.prototype.totalPoints = function() {
      var course, key, points, _ref;
      points = 0;
      _ref = this.courses;
      for (key in _ref) {
        course = _ref[key];
        if (course) {
          points += course.points;
        }
      }
      return points;
    };

    Calendar.prototype.fillFromURL = function(semester) {
      var arr, arr2, callnum, callnums, j, ptr, sec, _i, _j, _len, _len1;
      ptr = this;
      console.log($location.hash());
      callnums = $location.hash().split(',');
      arr = [];
      for (_i = 0, _len = callnums.length; _i < _len; _i++) {
        callnum = callnums[_i];
        if (callnum !== '') {
          j = new Section(callnum, semester);
          if (j !== null) {
            arr.push(j);
          }
        }
      }
      arr2 = [];
      for (_j = 0, _len1 = arr.length; _j < _len1; _j++) {
        sec = arr[_j];
        arr2.push(sec.fillData(Course));
      }
      return $q.all(arr2).then(function() {
        var _k, _len2, _results;
        _results = [];
        for (_k = 0, _len2 = arr.length; _k < _len2; _k++) {
          sec = arr[_k];
          _results.push(ptr.sectionChosen(sec));
        }
        return _results;
      });
    };

    Calendar.prototype.updateURL = function() {
      var key, section, str, _ref;
      str = "";
      _ref = this.sections;
      for (key in _ref) {
        section = _ref[key];
        if (section) {
          str = str + section.data['CallNumber'] + ",";
        }
      }
      if (str && str.charAt(str.length - 1) === ',') {
        str = str.slice(0, -1);
      }
      if ($location.hash() !== str) {
        return $location.hash(str);
      }
    };

    Calendar.prototype.addCourse = function(course) {
      if (this.courses[course.id]) {
        alert('Warning: you have already selected this course');
        return;
      }
      if (course.sections.length < 1) {
        alert('Warning: this course has no scheduled sections');
        return;
      }
      if (course.sections.length > 1) {
        return this.showAllSections(course);
      } else {
        this.sectionChosen(course.sections[0]);
        return this.updateURL();
      }
    };

    Calendar.prototype.addSection = function(section, canoverlap) {
      var day, i, subsection, _i, _j, _len, _len1, _ref;
      if (canoverlap == null) {
        canoverlap = true;
      }
      this.courses[section.id] = section.parent;
      if (section.overlapCheck(this.courseCalendar)) {
        if (!canoverlap) {
          alert('Warning: this overlaps with a course you have already selected');
        }
      }
      _ref = section.subsections;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        day = _ref[i];
        for (_j = 0, _len1 = day.length; _j < _len1; _j++) {
          subsection = day[_j];
          this.courseCalendar[i].push(subsection);
        }
      }
      return true;
    };

    Calendar.prototype.removeCourse = function(id) {
      var day, i, _i, _len, _ref;
      _ref = this.courseCalendar;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        day = _ref[i];
        this.courseCalendar[i] = this.courseCalendar[i].filter(function(subsection) {
          if (subsection.id === id) {
            return false;
          }
          return true;
        });
      }
      this.courses[id] = false;
      return this.sections[id] = false;
    };

    Calendar.prototype.sectionChosen = function(section, updateurl) {
      if (updateurl == null) {
        updateurl = true;
      }
      section.parent.status = null;
      this.removeCourse(section.id);
      this.sections[section.id] = section;
      return this.addSection(section, false);
    };

    Calendar.prototype.showAllSections = function(course) {
      var section, _i, _len, _ref, _results;
      course.status = "overlapping";
      _ref = course.sections;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        section = _ref[_i];
        _results.push(this.addSection(section));
      }
      return _results;
    };

    Calendar.prototype.changeSections = function(course) {
      this.removeCourse(course.id);
      return this.showAllSections(course);
    };

    Calendar.getValidSemesters = function() {
      var effectiveMonth, i, month, semester, semesters, year, _i;
      semesters = [];
      month = new Date().getMonth();
      year = new Date().getFullYear();
      effectiveMonth = month + 2;
      for (i = _i = 0; _i <= 2; i = ++_i) {
        if (effectiveMonth > 11) {
          effectiveMonth %= 12;
          year++;
        }
        semester = Math.floor(effectiveMonth / 4) + 1;
        effectiveMonth += 4;
        semesters.push(year + '' + semester);
      }
      semesters;

      return semesters = ['20133', '20141'];
    };

    Calendar.hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];

    Calendar.days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    return Calendar;

  })();
});
