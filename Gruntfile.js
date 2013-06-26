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
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');

  grunt.registerTask('default', ['coffee']);

};
