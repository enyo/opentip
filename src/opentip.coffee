###
More info at http://www.opentip.org

Copyright (c) 2012, Matias Meno
Graphics by Tjandra Mayerhold

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
###

###
Usage:

<div data-ot="This will be viewed in tooltip"></div>

or externally:

$('elementId').addTip('Content', { options });

For a full documentation, please visit http://www.opentip.org/
###


Opentip =

  version: "2.0.0-dev"

  STICKS_OUT_TOP: 1
  STICKS_OUT_BOTTOM: 2
  STICKS_OUT_LEFT: 1
  STICKS_OUT_RIGHT: 2

  cached: { }

  debugging: off

  # Just forwards to console.debug if @debugging is true and console.debug exists.
  debug: -> console.debug.apply console, arguments if @debugging and console?.debug?


  objectIsEvent: (obj) ->
    # There must be a better way of doing this.
    typeof (obj) is "object" and obj.type and obj.screenX

  lastTipId: 1

  lastZIndex: 100

  documentIsLoaded: no

  postponeCreation: (createFunction) ->
    # Sorry IE users but... well: get another browser!
    Event.observe window, "load", createFunction  unless Opentip.documentIsLoaded or not Opentip.IEVersion() 

  
  # A list of possible adapters. Used for testing
  adapters: { }

  # The current adapter used.
  adapter: null



  position:
    top: 0
    topRight: 1
    right: 2
    bottomRight: 3
    bottom: 4
    bottomLeft: 5
    left: 6
    topLeft: 7
  
  # In the future every position attribute will go through this method.
  sanitizePosition: (arrayPosition) ->
    if arrayPosition instanceof Array
      positionString = ""
      if arrayPosition[0] is "center"
        positionString = arrayPosition[1]
      else if arrayPosition[1] is "middle"
        positionString = arrayPosition[0]
      else
        positionString = arrayPosition[1] + @ucfirst arrayPosition[0]
    else if typeof arrayPosition == "string"
      positionString = arrayPosition
    
    position = @position[positionString]
    
    throw "Unknown position: " + positionString unless position?
    position

  
  # Browser support testing 
  vendors: "Khtml Ms O Moz Webkit".split(" ")
  testDiv: document.createElement("div")
  supports: (prop) ->
    return true  if prop of Opentip.testDiv.style
    prop = @ucfirst prop
    Opentip.vendors.any (vendor) ->
      vendor + prop of Opentip.testDiv.style









# Utils
Opentip.ucfirst = (string) -> string.charAt(0).toUpperCase() + string.slice(1)


