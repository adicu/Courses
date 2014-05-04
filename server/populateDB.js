Meteor.startup(function() {
  if (Courses.find().count() === 0 &&
    Sections.find().count() === 0) {

    var fs = Npm.require('fs');
    var path = Npm.require('path');

    var meteorRoot = fs.realpathSync(process.cwd() + '/../');
    var appRoot = fs.realpathSync(meteorRoot + '/../');

    // Only run on dev mode
    if (path.basename(fs.realpathSync(meteorRoot + '/../../../' )) == '.meteor'){
      appRoot = fs.realpathSync(meteorRoot + '/../../../../');
      console.log('Importing only COMS courses into the database');
      console.log('**Adding other courses will not work!**');
    } else {
      return;
    }

    var exec = Npm.require('child_process').exec;
    // NOTE: Hardcoded location
    exec(appRoot + '/scripts/minidump_import.sh localhost 3001',
      function(err, stdout, stdin) {
        if (err) {
          console.log('Import script failed: ' + err);
        }
      }
    );
  }
});
