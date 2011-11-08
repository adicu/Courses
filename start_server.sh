rake ts:start RAILS_ENV=production
bundle exec thin start -d -S /tmp/thin.adicu_courses.sock -s 1 -e production
