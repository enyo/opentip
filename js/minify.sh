#!/bin/bash

minfile=min.js

function add_minified {
  echo "$1"
  uglifyjs "$1" >> $minfile
}

echo "" > $minfile

add_minified "prototype-1.7.js"
for i in scriptaculous-1.9/*; do
  add_minified "$i"
done
add_minified "opentip.js"
add_minified "excanvas.js"
