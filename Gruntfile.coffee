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
            # Angular-UI jQuery Passthrough - Shouldn't be needed anymore
            'bower_components/angular-ui-utils/modules/jq/jq.js'
            # Elastic.js Angular version
            'bower_components/elastic.js/dist/elastic.js'
            'bower_components/elastic.js/dist/elastic-angular-client.js'
            # Foundation JS
            'bower_components/foundation/js/foundation/foundation.js'
            'bower_components/foundation/js/foundation/foundation.forms.js'
            'bower_components/foundation/js/foundation/foundation.reveal.js'
            'bower_components/foundation/js/foundation/foundation.dropdown.js'
            # angular-easyfb
            'bower_components/angular-easyfb/angular-easyfb.js'
          ]
        # options:
        #   mangle: false
        #   beautify:
        #     width: 80
        #     beautify: true

    watch:
      scripts:
        files:
          ['src/**/*.coffee']
        tasks:
          ['build', 'clean']
        options:
          livereload: true

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-bower-task'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-forever'

  grunt.registerTask 'default', ['build', 'lib', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify:src', 'cssmin']
  grunt.registerTask 'lib', ['bower', 'uglify:lib']
