module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      src:
        ['generated/']

    coffee:
      src:
        files:
          'target/js/courses.js': [
            'src/js/**/*.coffee'
          ]
        options:
          bare: true
          sourceMap: true

    cssmin:
      src:
        files:
          'target/css/app.min.css': [
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
          'generated/js/courses.ngmin.js': ['target/js/courses.js']

    uglify:
      src:
        options:
          mangle: true
          sourceMap: 'target/js/courses.min.js.map'
          sourceMapIn: 'target/js/courses.js.map'
          sourceMapRoot: '/js'
          sourceMappingURL: '/js/courses.min.js.map'
        files:
          'target/js/courses.min.js': ['generated/js/courses.ngmin.js']

      lib:
        files:
          'target/lib/lib.min.js': [
            # Angular-UI jQuery Passthrough
            'bower_components/angular-ui-utils/modules/jq/jq.js'
            # Foundation JS
            'bower_components/components-foundation/js/foundation.min.js'
            # Elastic.js Angular version
            'bower_components/elastic.js/src/clients/elastic-angular-client.js'
            # BreezeJS
            'bower_components/breeze/Breeze.Client/Scripts/breeze.debug.js'
            'bower_components/breeze/Breeze.Client/Scripts/IBlade/breeze.dataService.mongo.js'
          ]

    watch:
      scripts:
        files:
          ['src/**/*.coffee']
        tasks:
          ['default']
        options:
          livereload: true

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-cssmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-forever'
  grunt.loadNpmTasks 'grunt-usemin'

  grunt.registerTask 'default', ['build', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify', 'cssmin']
