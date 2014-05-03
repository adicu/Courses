# Courses

ADI's schedule builder for Columbia.

Build instructions:

1. Install [node.js](http://nodejs.org/)
2. Install meteor: `curl https://install.meteor.com/ | sh`
3. Install meteorite: `npm install -g meteorite`
4. Install meteor packages: `mrt install`
5. Run courses: `meteor`
6. View Courses at <http://localhost:3000/>

# App structure
This app structure is based on the recommendations [here](https://github.com/oortcloud/unofficial-meteor-faq#where-should-i-put-my-files)

> Note that most of the frontend code in is `client/` but that the
> frontend code may also access code in other directories
> (but not `tests/` and `server/`)

```
client/                     # Most of the frontend code
    lib/                    # client utlity code
      router.js             # **routes defined here**
    stylesheets/            # stylesheets for the whole app
    views/                  # **client view code**
    index.html              # Everything is injected into here
collections/                # db collections (client and server)
lib/                        # global utility code
    constants.js            # Various constants
public/                     # static files (ex. img)
scripts/                    # utility scripts not used by meteor
tests/                      # tests
smart.json                  # Meteor package manifest
```

## Testing
Laika is a wrapper around mocha, a common JS testing framework.
Note that in the documentation for Laika, TDD syntax is used,
but in our tests BDD syntax is used, which is more standard for
mocha. It starts an new instance of meteor for each test.

### Install laika
Documentation for laika [here](http://arunoda.github.io/laika/).

1. `sudo npm install -g laika underscore`
2. Install [phantomJS](http://phantomjs.org/download.html)
3. Run mongodb: `mongod --smallfiles --noprealloc --nojournal`

### Running
1. Run `laika` in project root.

This will run both unit and integration tests.

# Docker
The current `Dockerfile` included will create a data only container
(see [data container pattern](http://docs.docker.io/en/latest/use/working_with_volumes/))
when built with `docker build -t courses .` and run with
`docker run -d courses`.
This container should then be mounted by a container running a server
like nginx. A tool to automatically do this will follow.
