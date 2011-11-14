/*
---
MooTools: the javascript framework

web build:
 - http://mootools.net/core/7c56cfef9dddcf170a5d68e3fb61cfd7

packager build:
 - packager build Core/Core Core/Array Core/String Core/Number Core/Function Core/Object Core/Event Core/Browser Core/Class Core/Class.Extras Core/Slick.Parser Core/Slick.Finder Core/Element Core/Element.Style Core/Element.Event Core/Element.Dimensions Core/Fx Core/Fx.CSS Core/Fx.Tween Core/Fx.Morph Core/Fx.Transitions Core/Request Core/Request.HTML Core/Request.JSON Core/Cookie Core/JSON Core/DOMReady Core/Swiff

copyrights:
  - [MooTools](http://mootools.net)

licenses:
  - [MIT License](http://mootools.net/license.txt)
...
*/
Request.JSONP=new Class({Implements:[Chain,Events,Options],options:{onRequest:function(a){if(this.options.log&&window.console&&console.log){console.log("JSONP retrieving script with url:"+a);
}},onError:function(a){if(this.options.log&&window.console&&console.warn){console.warn("JSONP "+a+" will fail in Internet Explorer, which enforces a 2083 bytes length limit on URIs");
}},url:"",callbackKey:"callback",injectScript:document.head,data:"",link:"ignore",timeout:0,log:false},initialize:function(a){this.setOptions(a);},send:function(c){if(!Request.prototype.check.call(this,c)){return this;
}this.running=true;var d=typeOf(c);if(d=="string"||d=="element"){c={data:c};}c=Object.merge(this.options,c||{});var e=c.data;switch(typeOf(e)){case"element":e=document.id(e).toQueryString();
break;case"object":case"hash":e=Object.toQueryString(e);}var b=this.index=Request.JSONP.counter++;var f=c.url+(c.url.test("\\?")?"&":"?")+(c.callbackKey)+"=Request.JSONP.request_map.request_"+b+(e?"&"+e:"");
if(f.length>2083){this.fireEvent("error",f);}var a=this.getScript(f).inject(c.injectScript);this.fireEvent("request",[a.get("src"),a]);Request.JSONP.request_map["request_"+b]=function(){this.success(arguments,b);
}.bind(this);if(c.timeout){(function(){if(this.running){this.fireEvent("timeout",[a.get("src"),a]).fireEvent("failure").cancel();}}).delay(c.timeout,this);
}return this;},getScript:function(a){return this.script=new Element("script",{type:"text/javascript",src:a});},success:function(b,a){if(!this.running){return false;
}this.clear().fireEvent("complete",b).fireEvent("success",b).callChain();},cancel:function(){return this.running?this.clear().fireEvent("cancel"):this;
},isRunning:function(){return !!this.running;},clear:function(){if(this.script){this.script.destroy();}this.running=false;return this;}});Request.JSONP.counter=0;
Request.JSONP.request_map={};

window.addEvent( 'domready', function() {
  var app = new App();
  app.render( $('app') );
  app.preload();
});

var data_api_url = "http://courses.adicu.com";


/* Extensions */

var decimalToDate = function( decimal ){
	return new Date( 0,0,0,Math.floor( decimal ),(decimal-Math.floor( decimal ))*60,0,0 );
};

var dateToDecimal = function( date ){
	return date.getHours() + date.getMinutes()/60.0;
};

var decimalToTime = function( decimal ){
  var date = decimalToDate( decimal );
  var time = String.from( date.get12HourHour() ) + ":";
  if ( date.getMinutes() < 10 ) time += "0";
  return time + String.from( date.getMinutes() ) + date.getDesignator();
};

Date.implement({
  get12HourHour: function(){ return (this.getHours() > 12) ? this.getHours() - 12 : (this.getHours() === 0) ? 12 : this.getHours(); },
  getDesignator: function(){ return (this.getHours() < 12) ? "am": "pm"; }
});

String.implement( 'pluralize', function( count, plural ){
  if ( count != 1 ) {
    if ( is_null_or_undefined( plural ) ) return this + 's';
    else return plural;
  }
  else { return this; }
});


/* General functions */

var is_null_or_undefined = function( val ){
  return val === null || val === undefined;
};

var hourToLabel = function( hour ){
  if ( hour < 12 ) {  return String.from( hour ) + "am" }
  else if ( hour === 12 ) { return "noon" }
  else { return String.from( hour%12 ) + "pm" }
};

var daysToAbbreviation = function( days ){
  var abbreviation = "";
  if ( days.contains( 'Monday' )){ abbreviation += "M"; }
  if ( days.contains( 'Tuesday' )){ abbreviation += "T"; }
  if ( days.contains( 'Wednesday' )){ abbreviation += "W"; }
  if ( days.contains( 'Thursday' )){ abbreviation += "R"; }
  if ( days.contains( 'Friday' )){ abbreviation += "F"; }
  return abbreviation;
};

var abbreviationToDays = function( abbrev ){
  var days = new Array();
  var str = abbrev.toLowerCase();

  if ( str.contains( 'm' ) ){ days.include( 'Monday' );  }
  if ( str.contains( 't' ) ){ days.include( 'Tuesday' ); }
  if ( str.contains( 'w' ) ){ days.include( 'Wednesday' ); }
  if ( str.contains( 'r' ) ){ days.include( 'Thursday' ); }
  if ( str.contains( 'f' ) ){ days.include( 'Friday' ); }
  return days;
};

var sortSections = function(a, b){
  if ( a.id < b.id ){ return -1; }
  else if ( a.id > b.id ){ return 1; }
  else { return 0; }
};

var showFade = function(){
  $('fade').setStyle( 'display', 'block' );
};

var hideFade = function(){
  $('fade').setStyle( 'display', 'none' );
};


/* Classes */

var Error = new Class({
  initialize: function( message ){
    this.setMessage( message );
    this.root_message; },
  options: { class_name: "errorMessage"  },
  setMessage: function( message ){ this.message = message; },
  destroy: function(){ this.root_element.destroy(); hideFade();  },
  render: function(){
    this.root_element = new Element( 'div', { 'class': this.options.class_name });
    var backdrop = new Element( 'div', { 'class': "backdrop" });
    var container = new Element( 'div', { 'class': "box" });
    backdrop.inject( this.root_element );
    container.inject( this.root_element );
    this.message.inject( container );
    showFade();
    this.root_element.inject( document.body );
  }
});

var Instructor = new Class({
  initialize: function( data ){
    this.name = data.name;
    this.rank = data.culpa_rank;
    this.link = data.culpa_link;
  },
  getName: function(){ return ( is_null_or_undefined( this.name ) ) ? 'Unknown' : this.name; }
});

var Section = new Class({
  initialize: function( data, course ){
    this.call_number = data.call_number;
    this.title = data.title;
    this.instructor = new Instructor( data.instructor );
    this.building = data.building;
    this.room = data.room;
    this.section_number = data.section_number;
    this.description = data.description;
    this.enrollment = data.enrollment;
    this.max_enrollment = data.max_enrollment;
    this.url = data.url;
    this.start = data.start;
    this.end = data.end;
    this.days = abbreviationToDays( data.days );
    this.id = data.id;
    this.course = course;
  },
  getId:function() { return this.id; },
  getCallNumber: function() { return this.call_number; },
  getDays: function(){ return this.days; },
  getStart: function(){ return this.start; },
  getEnd: function(){ return this.end; },
  getSectionGroup: function(){ return new SectionGroup( this.days, this.start, this.end ); },
  getLength: function(){ return this.end - this.start; },
  getInstructor: function(){ return this.instructor; },
  getLocation: function(){ return ( is_null_or_undefined( this.building ) ) ? 'To be annouced' : this.room + ' ' + this.building; },
  getEnrollment: function(){ return ( is_null_or_undefined( this.enrollment ) ) ? 0 : this.enrollment; },
  getMaxEnrollment: function(){ return ( is_null_or_undefined( this.max_enrollment ) ) ? 0 : this.max_enrollment; },
  getDescription: function(){ return this.description; },
  getTitle: function(){ return this.title; },
  getURL: function(){ return this.url; },
  getCourse: function(){ return this.course; },
  setCourse: function( course ){ this.course = course; },
  overlaps: function( other ){
    if (
      (other.getStart() >= this.start && other.getStart() < this.end) ||
      (other.getEnd() > this.start && other.getEnd() < this.end) ||
      (other.getStart() <= this.start && other.getEnd() >= this.end) ) {
				var days_length = this.days.length;
        for( var i = 0; i < days_length; i++ ) { if ( other.getDays().contains( this.days[i] ) ) return true; }
    }
    else { return false; }
  }
});

/* Don't allow too many words in a description. */
var trimDescription = function(description, cutoff) {
  cutoff = cutoff || 100;
  var splitDescription = description.split(' ');
  if (splitDescription.length > cutoff) {
    return splitDescription.slice(0, cutoff).join(' ') + '...';
  }
  return description;
};

var Course = new Class({
  initialize: function( data ){
    this.id = data.id;
    this.title = data.title || '';
    this.description = trimDescription(data.description || '');
    this.course_key = data.course_key;
    this.num_sections = data.num_sections;
  },
  getId: function(){ return this.id; },
  getTitle: function(){ return this.title; },
  getFullTitle: function() {
      return this.course_key + (this.title ? ' ' + this.title : '');
  },
  getDescription: function(){ return this.description; },
  getCourseKey: function(){ return this.course_key; },
  isValid: function() { return this.id }
});

var SectionGroup = new Class({
  initialize: function( days, start, end ){
    this.days = days;
    this.start = start;
    this.end = end;
    this.sections = new Array();
  },
  getDays: function(){ return this.days; },
  getStart: function(){ return this.start; },
  getEnd: function(){ return this.end; },
  addSection: function( section ){ this.sections.include( section ); },
  getSections: function(){ return this.sections; },
  contains: function( other ){
    if (this.start <= other.getStart() && this.end >= other.getEnd()) {
      if ( this.days.length < other.getDays().length ) { return false; }
      other.getDays().each( function( day, index ){
        if ( !this.days.contains( day ) ) { return false; }
        }, this);
      return true;
    }
    else { return false; }
  }
});

var Calendar = new Class({
    initialize: function(){
      this.sections = new Array();
      this.build();
      this.browser;
    },
    options: {
      pixels_per_hour: 42,
      calendar_id: 'calendar',
      start_hour: 9,
      num_hours: 14,
      days: [ "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" ],
      day_pixel_width: 200
    },
    setBrowser: function( browser ){ this.browser = browser; },
    getTimeSlotWrapper: function( start, end, key, val ){
      var start_pixels = (start-this.options.start_hour) * this.options.pixels_per_hour;
      var height_pixels = Math.abs(end-start)*this.options.pixels_per_hour;
      var wrapper = new Element( 'div', {
        'class': 'timeSlotWrapper',
        styles: {
          top: String.from(Math.round(start_pixels)) + 'px',
          height: String.from(Math.round(height_pixels)) + 'px' }
        });
      wrapper.setProperty( key, val );
      return wrapper;
    },
    addSection: function( section ){
      if ( !this.sections.contains( section ) ) {
        // check if this section overlaps with existing sections, and prompt user for action if it does
				var sections_length = this.sections.length;
        for( var i = 0; i < sections_length; i++ ) {
          var o_section = this.sections[i];
          if ( section.overlaps( o_section ) ) {
            var error = new Error();
            var other_title = o_section.title || "An existing section";
            var message = new Element( 'div', {
              html: "<p>" + other_title + " overlaps with the section you're attempting to add. Do you want to replace it?</p>" });
            var stop = new Element( 'button', {
              html: "Stop", events: { click: function(){ error.destroy(); }}}).inject( message );
            var replace = new Element( 'button', {
              html: "Replace", events: { click: function(){ this.removeSection( o_section ); this.addSection( section ); error.destroy(); }.bind(this)}
              }, this).inject( message );

            error.setMessage( message );
            error.render();
            return;
          }
        };

        // no conflict; add section to calendar
        this.sections.include( section );
        this.updateURL();
        var section_popup = this.buildSectionPopup( section ).inject( document.body );
        section.getDays().each( function( day, index ){
          var section_wrapper = this.getTimeSlotWrapper( section.getStart(), section.getEnd(), 'sectionid', section.getId() ).inject( $(day) );
          section_wrapper.addEvent( 'click', function( event ){
            $$( 'div.timeslot_popup' ).each( function( element, index ){ element.setStyle( 'display', 'none' ); });
            showFade();
            section_popup.setStyle( 'display', 'block' );
            });
          section_timeslot = this.buildSectionTimeSlot( section ).inject( section_wrapper );
        }.bind(this));
      }
    },
    addCourse: function( course, semester ){
      // remove all existing course elements
      $$('div[courseid]').each( function( element, index ){ element.destroy(); });

      // check if calendar already as section from this course; prompt user for action if it does.
			var sections_length = this.sections.length;
      for( var i = 0; i < sections_length; i++ ){
        if ( this.sections[i].getCourse().getId() === course.getId() ){
          var error = new Error();
          var message = new Element( 'div', {
            html: "<p>You have already added a section for this course. Do you want to replace the existing section with this one?</p>" });
          var stop = new Element( 'button', {
            html: "Stop", events: { click: function(){ error.destroy(); }}}).inject( message );
          var replace = new Element( 'button', {
            html: "Replace", events: { click: function(){ this.removeSection( this.sections[i] ); error.destroy(); this.addCourse( course, semester )}.bind(this)}}, this).inject( message );
          error.setMessage( message );
          error.render();
          return;
        }
      }

      // no conflict, load course
      var request = new Request.JSONP({
        url: data_api_url + '/courses/get',
        callbackKey: 'callback',
        data: { course_key: course.getCourseKey(), s: semester },
        onComplete: function(data) {
          var sections = [];
          data.sections.each( function( section_data, index ) {
            if (section_data.days) {
              sections.include( new Section( section_data, course ));
            }
          });
          if (sections.length > 0) {
            this.addSections( sections );
          } else {
            var error = new Error();
            var message = new Element( 'div', {
              html: "<p>The sections for these class don't have any times. " +
                "This might be a placeholder class for registration, which we " +
                "don't support. If this is an error, please report a bug by " +
                "clicking the link at the bottom right of the page. </p>"
              });
            var stop = new Element( 'button', {
              html: "Okay", events: { click: function(){ error.destroy(); }}}).inject( message );
            error.setMessage( message );
            error.render();
          }
        }.bind(this)
      }, this).send();
    },
    addSections: function( sections ){
      if ( sections.length === 1 ) { this.addSection( sections[0] ); }
      else {
            var error = new Error();
            var message = new Element( 'div', {
              html: "<p>Multiple sections exist for this class. Please click on the section you like by clicking on it on the calendar.</p>" });
            var stop = new Element( 'button', {
              html: "Okay", events: { click: function(){ error.destroy(); }}}).inject( message );
            error.setMessage( message );
            error.render();

        var section_groups = new Array();
				var sections_length = sections.length;
        for( var i = 0; i < sections_length; i++ ){
          var section = sections[i];
          var added = false;
					var section_groups_length = section_groups.length;
          for( var j = 0; j < section_groups_length; j++ ){ if ( section_groups[j].contains( section ) ) { section_groups[j].addSection( section ); added = true; }}
          if ( !added ) {
            var section_group = section.getSectionGroup();
            section_group.addSection( section );
            section_groups.include( section_group );
          }
        }
        section_groups.each( function( sg, index ){
          if( sg.getSections().length > 1 ){ var sg_popup = this.buildSectionGroupPopup( sg ).inject( document.body ); }
          sg.getDays().each( function( day, index ){
            var sg_wrapper = this.getTimeSlotWrapper( sg.getStart(), sg.getEnd(), 'courseid', sg.getSections()[0].getCourse().getId() ).inject( $(day) );
            this.buildSectionGroupTimeSlot( sg ).inject( sg_wrapper );
            sg_wrapper.addEvent( 'click', function( event ){
              if ( sg.getSections().length > 1 ){
                $$( 'div.timeslot_popup' ).each( function( element, index ){ element.setStyle( 'display', 'none' ); });
                sg_popup.setStyle( 'display', 'block' );
              }
              else {
                this.removeCourse( sg.getSections()[0].getCourse() );
                this.addSection( sg.getSections()[0] );
              }
            }.bind(this));
          }.bind(this));
        }.bind(this));
      }
    },
    updateURL: function(){ window.location.hash = this.browser.getSemester() + ';' + this.sections.map( function( section, index ){ return section.getCallNumber(); }).join( ',' )},
    removeSection: function( section ){
      $$( '*[sectionid="' + section.getId() + '"]' ).each( function( element, index ){ element.destroy(); });
      this.sections.each( function( o_section, index ) { if ( section.getId() === o_section.getId() ) { this.sections.erase( section )}}.bind(this));
      this.updateURL();
    },
    removeCourse: function( course ){
      $$( '*[courseid="' + course.getId() + '"]' ).each( function( element, index ){ element.destroy(); });
    },
    reset: function() {
      this.sections.empty();
      $$( '*[courseid]' ).each( function( element, index ){ element.destroy(); });
      $$( '*[sectionid]' ).each( function( element, index ){ element.destroy(); });
    },
    build: function(){
      this.root_element = new Element( 'div', { id: this.options.calendar_id } );
      var table = new Element( 'table' ).inject( this.root_element );
      var guides = new Element( 'div', { id: 'guides' } ).inject( this.root_element );
      var daynames = new Element( 'thead', { id: 'daynames' } ).inject( table );
      var daynames_tr = new Element( 'tr' ).inject( daynames );
      var daybodies = new Element( 'tbody', { id: 'daybodies' } ).inject( table );
      var daybodies_tr = new Element( 'tr' ).inject( daybodies );
      var hours_td = new Element( 'td', { id: 'hours', 'class': 'hourColumn' } ).inject( daybodies_tr );

      // build day names and bodies
      var dayname_th = new Element( 'th', { style: 'height:' + this.options.pixels_per_hour + 'px' } ).inject( daynames_tr );
      Array.each( this.options.days, function( day, index ){
        new Element( 'th', { html: day, style: 'height:' + this.options.pixels_per_hour + 'px' } ).inject( daynames_tr );
        var day_element = new Element( 'td', { 'class': 'dayColumn', style: 'height:' + this.options.num_hours*this.options.pixels_per_hour + 'px' } ).inject( daybodies_tr );
        new Element( 'div', { id: day } ).inject( day_element );
        }, this );

			var options_num_hours = this.options.num_hours;
      for( var i = 0; i < options_num_hours; i++ ) {
        // build guide
        new Element( 'div', { id: String.from( this.options.start_hour+i ) + '-guide', style: 'height:' + (this.options.pixels_per_hour-1) + 'px;' }).inject( guides );
        // build hour label
        new Element( 'div', { html: hourToLabel( i+this.options.start_hour ), style: 'height:' + this.options.pixels_per_hour + 'px;' } ).inject( hours_td );
      }
    },
    buildSectionTimeSlot: function( section ){
      var canvas = new Element( 'div', { class: 'timeSlot' } );
      var title = new Element( 'p', {
          html: section.getTitle(),
          'class': 'timeSlotText timeSlotTitle'
      }).inject( canvas );
      var call_number = new Element( 'p', {
        html: 'Call #: ' + section.getCallNumber(),
        'class': 'timeSlotText timeSlotCallNumber'
      }).inject( canvas );
      var remove_link = new Element( 'button', {
          'class': "remove_link",
          html: "x"
      }).inject( canvas );
      remove_link.addEvent( 'click', function() {
        this.removeSection( section );
      }.bind(this));
      return canvas;
    },
    buildSectionPopup: function( section ){
      var canvas = new Element( 'div', {
        'class': "timeslot_popup", sectionid: section.getId(), styles: { display: 'none' }}, this);
      var box = new Element( 'div', {
        'class': "box", html: "<h2>Section details</h2>" }).inject( canvas );
      new Element( 'div', {
        'class': "backdrop", events: { click: function(){ canvas.setStyle( 'display', 'none' ); }}}).inject( canvas );
      new Element( 'button', {
        'class': "remove_link", html: "x", events: { click: function(){ canvas.setStyle( 'display', 'none' ); hideFade(); }}}).inject( box );

      var table = new Element( 'table' ).inject( box );
      new Element( 'tr', { 'class': 'title', html: '<td>Title:</td><td>' + section.getCourse().getFullTitle() + '; ' + section.getTitle() + '</td>' }).inject( table );
      new Element( 'tr', { 'class': 'time_slot', html: '<td>Call #:</td><td>' + section.getCallNumber() + '</td>' }).inject( table );
      new Element( 'tr', {
        html: '<td>Time slot:</td><td>'+
          daysToAbbreviation( section.getDays() ) + ', ' +
          decimalToTime( section.getStart() ) + "-" +
          decimalToTime( section.getEnd() ) + '</td>'}).inject( table );
      new Element( 'tr', { 'class': 'instructor', html: '<td>Instructor:</td><td>' + section.getInstructor().getName() + '</td>' }).inject( table );
      new Element( 'tr', { 'class': 'location', html: '<td>Location:</td><td>' + section.getLocation() + '</td>' }, this).inject( table );
      new Element( 'tr', { 'class': 'section_description', html: '<td>Description:</td><td>' + section.getDescription() + '</td>' }, this).inject( table );
      new Element( 'tr', { 'class': 'url', html: '<td></td><td>' + '<a target="_blank" href="' + section.getURL() + '">Directory listing</a>' + '</td>'}).inject( table );
      return canvas;
    },
    buildSectionGroupPopup: function( sg ){
      var canvas = new Element( 'div', { 'class': "timeslot_popup", courseid: sg.getSections()[0].getCourse().getId(), styles: { display: 'none' }});
      var backdrop = new Element( 'div', { 'class': 'backdrop', events: { click: function(){ canvas.setStyle( 'display', 'none' ); }}}).inject( canvas );
      var box = new Element( 'div', { 'class': "box", html: "<h2>Select a section:</h2>" } ).inject( canvas );
      new Element( 'button', { 'class': "remove_link", html: "x", events: { click: function(){ canvas.setStyle( 'display', 'none' ); }}}).inject( box );

      var table = new Element( 'table' ).inject( box );
      new Element( 'thead', { html: '<tr><th>Instructor</th><th>Location</th></tr>'}).inject( table );
      var tbody = new Element( 'tbody' ).inject( table );
      sg.getSections().each( function( section, index ){
        var s_row = new Element( 'tr' ).inject( tbody );
        new Element( 'td', { html: section.getInstructor().getName()}).inject( s_row );
        new Element( 'td', { html: section.getLocation() }).inject( s_row );
        var s_selector_td = new Element( 'td' ).inject( s_row );
        new Element( 'button', { html: "Add", events: { click: function(){ this.removeCourse( section.getCourse() ); this.addSection( section ) }.bind(this)}}, this).inject( s_selector_td );
      }.bind(this));
      return canvas;
    },
    buildSectionGroupTimeSlot: function( sg ){
      var canvas = new Element( 'div', { 'class': "timeslot_canvas" } );
      new Element( 'p', { html: sg.getSections()[0].getCourse().getTitle() }).inject( canvas );
      new Element( 'p', { html: String.from( sg.getSections().length ) + ' ' + String.from('section').pluralize( sg.getSections().length )}).inject( canvas );
      return canvas;
    },
    render: function( parent_el ){ this.root_element.inject( parent_el );  }
  });

var Browser = new Class({
  initialize: function(){
    this.build();
  },
  options: {
    browser_id: "browser",
    limit: 10
  },
  setCalendar: function( calendar ){ this.calendar = calendar; },
  build: function(){
    this.root_element = new Element( 'div', { id: this.options.browser_id });
    this.search_element = new Element( 'div', { 'class': 'search' }).inject( this.root_element );
    this.results_element = new Element( 'div', { 'class': 'results', styles: { display: 'none' }}).inject( this.root_element );
    this.results_container = new Element( 'ul' ).inject( this.results_element );
    new Element( 'p', { 'class': 'clear_results', html: "Clear results", events: { click: function(){ this.clearResults() }.bind(this)}}, this).inject( this.results_element );

    this.search_input = new Element( 'input', {
      type: 'text',
      name: 'search_input',
      value: 'Type a course title to begin...',
      styles: { color: '#BCBCBC' }}).inject( this.search_element );
    this.semester_element = new Element( 'select', { 'class': 'semester' }).inject( this.search_element );
    this.search_submit = new Element( 'button', { html: 'Search', events: { click: function(){ this.submitSearch(); }.bind(this)}}, this).inject( this.search_element );

    var clear_on_click = function(){
      this.setProperty( 'value', '' );
      this.setStyle( 'color', 'black' );
      this.removeEvent( 'focus', clear_on_click );
    }

    this.search_input.addEvent( 'focus', clear_on_click );
    this.search_input.addEvent('keydown', function( event ) { if( event.key === "enter") { this.submitSearch(); }}.bind(this));

    var month = new Date().getMonth() + 1 + 2;
    var year = new Date().getFullYear();

    for( var i = 0; i < 3; i++ ){
      if ( month > 11 ){ month %= 12; year++; }
      var semester = String.from(Math.floor(month/4)+1);
      var string;
      switch( semester ) {
        case '1':
          string = 'Spring';
          break;
        case '2':
          string = 'Summer';
          break;
        case '3':
          string = 'Autumn';
          break;
      }
      if ( i === 0 ) new Element( 'option', { value: String.from(year)+semester, html: string + ' ' + String.from(year), selected: 'selected' }).inject( this.semester_element );
      else new Element( 'option', { value: String.from(year)+semester, html: string + ' ' + String.from(year) }).inject( this.semester_element );
      month += 4;
    }
  },
  buildCourseLI: function( course ){
    var li = new Element( 'li', { 'class': 'course' });
    new Element( 'p', { 'class': "title", html: course.getFullTitle()}).inject( li );
    new Element( 'p', { 'class': "description", html: course.getDescription()}).inject( li );
    return li;
    },
  render: function( parent_el ){
    this.root_element.inject( parent_el );
  },
  setSemester: function( semester ){
    this.semester_element.getChildren().each(function(el){
      if ($(el).getProperty( 'value' ) === semester) $(el).setProperty( 'selected', true );
    });
  },
  getSemester: function(){ return this.semester_element.getSelected()[0].getProperty( 'value' ); },
  getSearchTerm: function(){ return this.search_input.getProperty( 'value' ); },
  submitSearch: function(){
    this.results_container.empty();
    this.loadResults();
  },
  loadResults: function( limit, page ){
    if ( is_null_or_undefined( limit ) ){ limit = this.options.limit; }
    if ( is_null_or_undefined( page ) ){ page = 1; }
    var semester = this.getSemester();
    var request = new Request.JSONP({
      url: data_api_url + '/courses/search',
      callbackKey: 'callback',
      data: {
        q: this.getSearchTerm(),
        s: semester,
        l: limit,
        p: page
      },
      onComplete: function( data ){
        if ( $('more_results') ){ $('more_results').destroy(); }
        if ( data.results.length > 0 ){
          data.results.each( function( course_data, index ){
            var course = new Course( course_data );
            if (course.isValid()) {
              this.buildCourseLI( course ).addEvent( 'click', function( event ){
                this.calendar.addCourse( course, semester );
                this.results_element.setStyle( 'display', 'none' );
              }.bind(this)).inject( this.results_container );
            }
          }, this);
          if( data.num_results > page * limit ) {
            var remaining_results = data.num_results - page*limit;
            var string = remaining_results + ' more ' + String.from('result').pluralize(remaining_results);
            string += ( remaining_results <= limit )? ' (view all)' : ' (view ' + limit + ' more)';
            new Element( 'li', { id: 'more_results', html: '<p>' + string + '</p>', events: { click: function(){ this.loadResults( limit, page+1 ); }.bind(this)}}, this).inject( this.results_container );
          }
        }
        else {
          new Element( 'li', { id: 'no_results', html: "No results found for " + '<strong>"' + this.getSearchTerm() + '"</strong>' + ". Please try rewording your query." }).inject( this.results_container );
        }
        this.results_element.setStyle( 'display', 'block' );
      }.bind( this )
    }, this).send();
  },
  reset: function(){
    this.clearResults();
    this.search_input.setProperty( 'value', '' );
  },
  clearResults: function(){
    this.results_container.empty();
    this.results_element.setStyle( 'display', 'none' );
    scroll(0,0);
  }
});

var App = new Class({
  initialize: function(){
    this.calendar = new Calendar();
    this.browser = new Browser();
    this.calendar.setBrowser( this.browser );
    this.browser.setCalendar( this.calendar );
  },
  render: function( parent_el ){
    new Element( 'button', { id: 'print', html: 'Print', events: { click: function(){ window.print(); }}}).inject( parent_el );
    this.browser.render( parent_el );
    this.calendar.render( parent_el );
  },
  reset: function() { this.browser.reset(); this.calendar.reset(); },
  preload: function(){
    var params = window.location.hash.replace( '#', '' ).split( ';' );
    var semester = params[0];
    if ( semester ) this.browser.setSemester( semester );

    if ( params[1] != undefined ) {
      var call_numbers = params[1].split( ',' ).filter( function( item, index ){ return ( item.trim() != "" )});
      if ( call_numbers.length > 0 ){
        var request = new Request.JSONP({
	  url: data_api_url + '/sections/get',
          callbackKey: 'callback',
          data: { "call_number": call_numbers, "s": semester },
          onComplete: function( data ){
            data.each( function( data_item, index ){
              this.calendar.addSection( new Section( data_item, new Course( data_item.course ) ) );
            }.bind(this));
          }.bind(this)
        }, this).send();
      }
    }
  }
});

