
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

  $: -> @wrap.apply @, arguments

  # Returns the unwrapped element
  unwrap: (element) -> @$(element)[0]

  # Returns the tag name of the element
  tagName: (element) -> @$(element)[0].tagName

  # Returns or sets the given attribute of element
  attr: (element, attr, value) ->
    if value?
      @$(element)[0].setAttribute attr, value
    else
      @$(element)[0].getAttribute? attr

  # Finds elements by selector
  find: (element, selector) -> @$(element)[0].querySelector selector

  # Finds all elements by selector
  findAll: (element, selector) -> @$(element)[0].querySelectorAll selector

  # Add a class
  addClass: (element, className) -> @$(element)[0].classList.add className

  # Updates the content of the element
  update: (element, content, escape) ->
    element = @$(element)[0]
    if escape
      element.innerHTML = "" # Clearing the content
      element.appendChild document.createTextNode content
    else
      element.innerHTML = content

  # Remove a class
  removeClass: (element, className) -> @$(element)[0].classList.remove className

  # Set given css properties
  css: (element, properties) ->
    element = @unwrap @$ element
    for own key, value of properties
      element.style[key] = value

  # Observe given eventName
  observe: (element, eventName, observer) -> @$(element)[0].addEventListener eventName, observer

  # Stop observing event
  stopObserving: (element, eventName, observer) -> @$(element)[0].removeEventListener eventName, observer


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
Opentip.adapters.native = adapter
# Set as adapter in use
Opentip.adapter = adapter
