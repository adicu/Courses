module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    bower:
      install:
        options:
          copy: false

    clean:
      src:
        ['generated/']

    coffee:
      src:
        files:
          'public/js/courses.js': [
            'src/js/**/*.coffee'
          ]
        options:
          bare: true
          sourceMap: true

    # Minifies the CSS files. Deprecated.
    cssmin:
      src:
        files:
          'public/css/app.min.css': [
            'src/css/**/*.css'
          ]

    forever:
      options:
        index: 'app/server.coffee'
        command: 'coffee'
        logDir: 'logs'

    # Generates the CSS files from less files
    less:
      src:
        files:
          'public/css/app.min.css': [
            'src/css/**/*.less'
          ]
        options:
          yuicompress: true

    ngmin:
      compile:
        files:
          'generated/js/courses.ngmin.js': ['public/js/courses.js']

    uglify:
      src:
        files:
          'public/js/courses.min.js': ['generated/js/courses.ngmin.js']
        options:
          mangle: true
          sourceMap: 'public/js/courses.min.js.map'
          sourceMapIn: 'public/js/courses.js.map'
          sourceMapRoot: '/js'
          sourceMappingURL: '/js/courses.min.js.map'

      lib:
        files:
          'public/lib/lib.min.js': [
            # Angular-UI jQuery Passthrough
            'bower_components/angular-ui-utils/modules/jq/jq.js'
            # Foundation JS
            'bower_components/foundation/js/foundation/foundation.js'
            'bower_components/foundation/js/foundation/foundation.forms.js'
            'bower_components/foundation/js/foundation/foundation.reveal.js'
            'bower_components/foundation/js/foundation/foundation.dropdown.js'
            # angular-easyfb
            'bower_components/angular-easyfb/angular-easyfb.js'
            # Custom version of angular-strap
            'src/lib/angular-strap.js'
            # Additional lib files in index.html
          ]
        # options:
        #   mangle: false
        #   beautify:
        #     width: 80
        #     beautify: true

    # Watch coffee files and build js files when coffeescript files changed
    watch:
      scripts:
        files:
          ['src/**/*.coffee']
        tasks:
          ['build', 'clean']
        options:
          debounceDelay: 250
          livereload: true
          spawn: false

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-forever'

  grunt.registerTask 'default', ['build', 'lib', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify:src', 'less']
  grunt.registerTask 'lib', ['bower', 'uglify:lib']
