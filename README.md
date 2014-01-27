# Courses

ADI's schedule builder for Columbia.

Build instructions:

1. Set up [npm](http://nodejs.org/download/) (at least 0.8.0).
2. `sudo npm install -g grunt-cli coffee-script bower`
3. In this project directory: `npm install`
4. In this project directory: `grunt`
5. Serve `public/` however you like.
  `python -m SimpleHTTPServer` for example.
6. Go to `localhost:8000`.
7. Keep `grunt watch` running to compile changes.

# App structure
```
|-- app/ (backend code)
|-- public/ (directory with minified code to be served -
      this is not complete initially, completed by grunt)
|-- scripts/ (Various one off scripts)
|-- src/ (code to be compiled)
 \
  |-- css/ (less files to be compiled to CSS)
  |-- js/ (coffescript files - most of the Angular code)
   \
    |-- controllers/ (the C in MVC)
    |-- directives/ (See angular directives)
    |-- models/ (Plain old Coffescript classes, M in MVC)
    |-- services/ (See angular services)
    |-- app.coffee (Main init code for Angular, where Angular
          packages are required)
    |-- constants.coffee (Various constants)
    |-- filters.coffee (See angular filters)
  |-- lib/ (Library js files that have been edited/tweaked)
|-- test/
|-- bower.json (bower package manifest)
|-- package.json (npm package manifest)
|-- README.md (This file)
```

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
