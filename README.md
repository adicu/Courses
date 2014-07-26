# Courses

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

# Testing
Tests are currently in the `tests/mocha-web-velocity` directory.
Editing and saving any of these tests will cause them to be automatically rerun.
See the status of tests by clicking the on circle on the top right corner of the
page (will only be shown in development mode).

# Docker
Docker support is coming soon.
*Note:* Docker support is for deployment, as you lose all of the reactive goodness (automatic reloading) if Meteor isn't running locally.
