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
          // Opentip v2.2.4
          // Copyright (c) 2009-2012
          // www.opentip.org
          // MIT Licensed

          """



# First download excanvas
console.log "Downloading excanvas"

request "https://raw.github.com/enyo/excanvas/master/index.js", (error, response, excanvas) ->
  return console.error error unless !error and response.statusCode == 200

  console.log "Downloading classList"
  request "https://raw.github.com/eligrey/classList.js/master/classList.js", (error, response, classList) ->
    return console.error error unless !error and response.statusCode == 200
      
    console.log "Downloading addEventListener polyfill"
    # request "https://gist.github.com/raw/4684074/e98964ff5aec0032cab344bd40c4f528dec7ac78/addEventListener-polyfill.js", (error, response, addEventListener) ->
    request "https://gist.github.com/raw/4684216/c58a272ef9d9e0f55ea5e90ac313e3a3b2f2b7b3/eventListener.polyfill.js", (error, response, addEventListener) ->
      return console.error error unless !error and response.statusCode == 200


      saveFile = (originalDownloadName, contents, withExcanvas) ->
        downloadName = originalDownloadName

        console.log "Minfiying and saving#{if withExcanvas then " with excanvas" else ""}..."

        if withExcanvas
          contents += "\n\n" + excanvas
          downloadName += "-excanvas"

        if originalDownloadName == "native"
          contents += "\n\n" + classList
          contents += "\n\n" + addEventListener

        targetFile = "#{__dirname}/opentip-#{downloadName}.js"

        fs.writeFileSync targetFile, contents, "utf-8"

        mergedMinified = header + uglifyJs2.minify(targetFile).code
        targetFile = "#{__dirname}/opentip-#{downloadName}.min.js"
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
