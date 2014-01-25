# Courses

ADI's schedule builder for Columbia.

Build instructions:

1. Set up [npm](http://www.npmjs.org/) (at least 0.8.0).
2. `sudo npm install -g grunt-cli coffee-script bower`
3. In this project directory: `npm install`
4. In this project directory: `grunt`
5. Serve `public/` however you like.
  `python -m SimpleHTTPServer` for example.
6. Go to `localhost:8000`.

## Testing

### Install protractor
```
npm install -g protractor
webdriver-manager update
webdriver-manager start
```

### Run tests
```
grunt test
```
This assumes that you have the application available at `localhost:8000`.
