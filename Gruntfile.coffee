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

    forever:
      options:
        index: 'app/server.coffee'
        command: 'coffee'
        logDir: 'logs'

    karma:
      unit:
        options:
          files: ['test/unit/*.coffee']

    # Generates the CSS files from less files
    less:
      src:
        files:
          'public/css/app.min.css': [
            'src/css/app.less',
            'bower_components/grid-5/index'
          ]
        options:
          yuicompress: true

    ngmin:
      compile:
        files:
          'generated/js/courses.ngmin.js': ['public/js/courses.js']

    protractor:
      e2e:
        options:
          configFile: 'test/protractor.conf.js'

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
            # elastic.js
            'bower_components/elastic.js/dist/elastic.js'
            'bower_components/elastic.js/dist/elastic-angular-client.js'
            # Export to iCal
            'bower_components/ics.js/ics.js'
            'bower_components/FileSaver.js/FileSaver.js'
            'bower_components/Blob.js/Blob.js'
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
          spawn: false
      less:
        files:
          ['src/css/*']
        tasks:
          ['less']

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-forever'
  grunt.loadNpmTasks 'grunt-karma'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-protractor-runner'

  grunt.registerTask 'default', ['build', 'lib', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify:src', 'less']
  grunt.registerTask 'lib', ['bower', 'uglify:lib']
  grunt.registerTask 'test', ['protractor:e2e']
