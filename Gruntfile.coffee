module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    clean:
      compile:
        ['generated/']

    coffee:
      compile:
        options:
          bare: true
          sourceMap: true

        files:
          'target/js/courses.js': [
            'src/js/**/*.coffee'
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
      compile:
        options:
          mangle: true
          sourceMap: 'target/js/courses.min.js.map'
          sourceMapIn: 'target/js/courses.js.map'
          sourceMapRoot: '/js'
          sourceMappingURL: '/js/courses.min.js.map'

        files:
          'target/js/courses.min.js': ['generated/js/courses.ngmin.js']

    watch:
      scripts:
        files:
          ['src/**/*.coffee']
        tasks:
          ['default']
        options:
          livereload: true

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-forever'

  grunt.registerTask 'default', ['build', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify']
