module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    coffee: {
      compile: {
        options: {
          bare: true
        },
        files: {
          'target/js/app.js': 'src/js/app.coffee',
          'target/js/controllers.js': 'src/js/controllers.coffee',
          'target/js/directives.js': 'src/js/directives.coffee',
          'target/js/filters.js': 'src/js/filters.coffee',
          'target/js/services.js': 'src/js/services.coffee'
        }
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-coffee');

  grunt.registerTask('default', ['coffee']);

};
