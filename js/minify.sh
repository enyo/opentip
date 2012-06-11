#!/bin/bash

minfile=min.js

function add_minified {
  echo "$1"
  uglifyjs -nm "$1" >> $minfile
}

function add {
  echo "$1"
  cat "$1" >> $minfile
}

echo "" > $minfile

add "prototype-1.7.js" # If I uglify prototype as well there are weird errors.
for i in scriptaculous-1.9/*; do
  add_minified "$i"
done
add_minified "opentip.js"
add_minified "excanvas.js"
