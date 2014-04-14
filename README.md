# Courses

ADI's schedule builder for Columbia.

Build instructions:

1. Run `vagrant up`
2. View Courses at <http://localhost:8080/>
3. Enjoy live recompilation of changed files.


**Hint**: [Notes.md](/Notes.md) has
some useful info for understanding Courses.

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

# Docker
The current `Dockerfile` included will create a data only container
(see [data container pattern](http://docs.docker.io/en/latest/use/working_with_volumes/))
when built with `docker build -t courses .` and run with
`docker run -d courses`.
This container should then be mounted by a container running a server
like nginx. A tool to automatically do this will follow.
