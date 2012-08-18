
# Native Opentip Adapter
# ======================
#
# Use this adapter if you don't use a framework like jQuery and you don't
# really care about oldschool browser compatibility.
class Adapter

  name: "Native"

  # Invoke callback as soon as dom is ready
  domReady: (callback) -> callback()



  # DOM
  # ===


  # Create the HTML passed as string
  create: (htmlString) ->
    div = document.createElement "div"
    div.innerHTML = htmlString
    div.childNodes



  # Element handling
  # ----------------

  # Wrap the element in the framework
  wrap: (element) ->
    element = [ element ] unless element instanceof Array or element instanceof NodeList
    element

  # Returns the tag name of the element
  tagName: (element) -> $(element)[0].tagName

  # Returns or sets the given attribute of element
  attr: (element, attr, value) ->
    if value?
      $(element)[0].setAttribute attr, value
    else
      $(element)[0].getAttribute? attr

  # Add a class
  addClass: (element, className) -> $(element)[0].classList.add className

  # Remove a class
  removeClass: (element, className) -> $(element)[0].classList.remove className

  # Observe given eventName
  observe: (element, eventName, observer, stopPropagation) ->
    obs = (e) ->
      if stopPropagation
        e.preventDefault()
        e.stopPropagation()
        e.stopped = yes
      observer.apply this, arguments

    $(element)[0].addEventListener eventName, obs


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

$ = adapter.wrap

# Add the adapter to the list
Opentip.adapters.native = adapter
# Set as adapter in use
Opentip.adapter = adapter
