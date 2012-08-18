# Ender Opentip Adapter
# =====================
#
# Uses ender packages

# Because $ is my favorite character
$ = ender

# Using bean as event handler
bean = require "bean"

# Augment ender
$.ender {
  opentip: (content, title, options) -> new Opentip this, content, title, options
}, true


# And now the class
class Adapter

  # Simply using $.domReady
  domReady: (callback) -> $.domReady callback


  # DOM
  # ===

  # Using bonzo to create html
  create: (html) -> $ html


  # Element handling
  # ----------------

  # Wraps the element in ender
  wrap: (element) ->
    element = $ element
    throw new Error "Multiple elements provided." if element.length > 1
    element

  # Returns the tag name of the element
  tagName: (element) -> $(element).get(0).tagName

  # Returns the given attribute of element
  attr: (element, attr) -> $(element).attr attr

  # Observe given eventName
  observe: (element, eventName, observer, stopPropagation) ->
    obs = (e) ->
      e.stop() if stopPropagation
      observer.apply this, arguments
    $(element).on eventName, obs



  # Utility functions
  # =================

  # Creates a shallow copy of the object
  clone: (object) ->
    newObject = { }
    for own key, val of object
      newObject[key] = val
    newObject

  # Copies all properties from sources to target
  extend: (target, sources...) ->
    for source in sources
      for own key, val of source
        target[key] = val
    target

# Create the adapter
adapter = new Adapter

# Add the adapter to the list
Opentip.adapters.ender = adapter
# Set as adapter in use
Opentip.adapter = adapter
