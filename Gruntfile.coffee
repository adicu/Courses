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

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-ngmin'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  grunt.registerTask 'default', ['build', 'clean']
  grunt.registerTask 'build', ['coffee', 'ngmin', 'uglify']
