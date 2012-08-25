
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
    @wrap div.childNodes



  # Element handling
  # ----------------

  # Wrap the element in the framework
  wrap: (element) ->
    if element instanceof NodeList
      element = (el for el in element)
    else if element not instanceof Array
      element = [ element ]
    element

  # Returns the unwrapped element
  unwrap: (element) -> @wrap(element)[0]

  # Returns the tag name of the element
  tagName: (element) -> @unwrap(element).tagName

  # Returns or sets the given attribute of element
  attr: (element, attr, value) ->
    if arguments.length == 3
      @unwrap(element).setAttribute attr, value
    else
      @unwrap(element).getAttribute? attr


  lastDataId = 0
  dataValues = { }
  # Returns or sets the given data of element
  data: (element, name, value) ->
    dataId = @attr element, "data-id"
    unless dataId
      dataId = ++lastDataId
      @attr element, "data-id", dataId
      dataValues[dataId] = { }

    if arguments.length == 3
      # Setter
      dataValues[dataId][name] = value
      console.log name, value
    else
      value = dataValues[dataId][name]
      return value if value?

      value = @attr element, "data-#{Opentip::dasherize name}"
      if value
        dataValues[dataId][name] = value
      return value



  # Finds elements by selector
  find: (element, selector) -> @unwrap(element).querySelector selector

  # Finds all elements by selector
  findAll: (element, selector) -> @unwrap(element).querySelectorAll selector

  # Updates the content of the element
  update: (element, content, escape) ->
    element = @unwrap element
    if escape
      element.innerHTML = "" # Clearing the content
      element.appendChild document.createTextNode content
    else
      element.innerHTML = content

  # Appends given child to element
  append: (element, child) ->
    unwrappedChild = @unwrap child
    unwrappedElement = @unwrap element
    unwrappedElement.appendChild unwrappedChild

  # Add a class
  addClass: (element, className) -> @unwrap(element).classList.add className

  # Remove a class
  removeClass: (element, className) -> @unwrap(element).classList.remove className

  # Set given css properties
  css: (element, properties) ->
    element = @unwrap @wrap element
    for own key, value of properties
      element.style[Opentip::dasherize key] = value

  # Returns an object with given dimensions
  dimensions: (element) ->
    element = @unwrap @wrap element
    {
      width: element.offsetWidth
      height: element.offsetHeight
    }

  # Returns an object with x and y 
  mousePosition: (e) ->
    pos = x: 0, y: 0

    e ?= window.event

    return unless e?

    if e.pageX or e.pageY
      pos.x = e.pageX
      pos.y = e.pageY
    else if e.clientX or e.clientY
      pos.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
      pos.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop

    pos

  # Returns the offset of the element
  offset: (element) ->
    element = @unwrap element

    offset = {
      top: element.offsetTop
      left: element.offsetLeft
    }

    while element = element.offsetParent
      offset.top += element.offsetTop
      offset.left += element.offsetLeft

      if element != document.body
        offset.top -= element.scrollTop
        offset.left -= element.scrollLeft

    offset

  # Observe given eventName
  observe: (element, eventName, observer) -> @unwrap(element).addEventListener eventName, observer

  # Stop observing event
  stopObserving: (element, eventName, observer) -> @unwrap(element).removeEventListener eventName, observer


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
