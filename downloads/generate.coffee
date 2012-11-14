#!/usr/bin/env coffee

fs = require "fs"
request = require "request"

uglifyJs2 = require "uglify-js2"


downloads =
  jquery: [
    "lib/opentip.js"
    "lib/adapter.jquery.js"
  ]
  prototype: [
    "lib/opentip.js"
    "lib/adapter.prototype.js"
  ]
  native: [
    "lib/opentip.js"
    "lib/adapter.native.js"
  ]


header =  """
          // Opentip v2.0.5-dev
          // Copyright (c) 2009-2012
          // www.opentip.org
          // MIT Licensed

          """


# First download excanvas
console.log "Downloading excanvas"

request "https://raw.github.com/enyo/excanvas/master/index.js", (error, response, excanvas) ->

  unless !error and response.statusCode == 200
    console.error error
    return

  saveFile = (downloadName, contents, withExcanvas) ->
    console.log "Minfiying and saving#{if withExcanvas then " with excanvas" else ""}..."

    if withExcanvas
      contents += "\n\n" + excanvas
      downloadName += "-excanvas"

    targetFile = "#{__dirname}/opentip-#{downloadName}.js"

    fs.writeFileSync targetFile, contents, "utf-8"

    mergedMinified = header + uglifyJs2.minify(targetFile).code
    fs.writeFileSync targetFile, mergedMinified, "utf-8"


  for downloadName, files of downloads
    merged = []
    console.log ""
    console.log "Processing '#{downloadName}.js'"
    for file in files
      console.log "Adding '#{file}'."
      merged.push fs.readFileSync "#{__dirname}/../#{file}", "utf-8"

    merged = merged.join "\n\n"

    saveFile downloadName, merged 
    saveFile downloadName, merged, yes

    console.log "Done"

  console.log ""
  console.log ""