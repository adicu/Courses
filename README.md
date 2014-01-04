# Courses

ADI's schedule builder for Columbia.

Build instructions:

1. Set up [npm](http://www.npmjs.org/) (at least 0.8.0).
2. `sudo npm install -g grunt-cli`
3. `sudo npm install -g coffee-script`
4. In this project directory: `npm install`
5. In this project directory: `grunt`
6. Serve `public/` however you like.
  `python -m SimpleHTTPServer` for example.
7. Go to `localhost:8000`.

Make sure you copy the Facebook client secret into `settings.courses`.

## Testing

### Install protractor
```
npm install -g protractor
webdriver-manager update
webdriver-manager start
```
