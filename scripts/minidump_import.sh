#!/bin/sh
set -o nounset

HOST=$1
PORT=$2

DIR="$( cd "$( dirname "$0" )" && pwd )"

mongoimport --host $HOST --port $PORT --db meteor \
  --collection sections --file $DIR/.dumps/sections.json
mongoimport --host $HOST --port $PORT --db meteor \
  --collection courses --file $DIR/.dumps/courses.json
