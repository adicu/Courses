#!/bin/bash
set -e

source settings.courses
./node_modules/coffee-script/bin/coffee app/server.coffee
