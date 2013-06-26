module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        options: {
          bare: true,
          sourceMap: true
        },
        files: {
          'target/js/courses.js': [
            'src/js/app.coffee',
            'src/js/controllers.coffee',
            'src/js/directives.coffee',
            'src/js/filters.coffee',
            'src/js/services.coffee'
          ]
        }
      }
    },
    uglify: {
      compile: {
        options: {
          mangle: false,
          sourceMap: 'target/js/courses.min.js.map',
          sourceMapIn: 'target/js/courses.js.map',
          sourceMapRoot: '/js',
          sourceMappingURL: '/js/courses.min.js.map'
        },
        files: {
          'target/js/courses.min.js': ['target/js/courses.js']
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('default', ['coffee', 'uglify']);

};
