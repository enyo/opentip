
# Native Opentip Adapter
# ======================
#
# Use this adapter if you don't use a framework like jQuery and you don't
# really care about oldschool browser compatibility.
class Adapter

  name: "native"

  # Invoke callback as soon as dom is ready
  # Source: https://github.com/dperini/ContentLoaded/blob/master/src/contentloaded.js
  domReady: (callback) ->
    done = no
    top = true
    win = window
    doc = document

    return callback() if doc.readyState in [ "complete", "loaded" ]

    root = doc.documentElement
    add = (if doc.addEventListener then "addEventListener" else "attachEvent")
    rem = (if doc.addEventListener then "removeEventListener" else "detachEvent")
    pre = (if doc.addEventListener then "" else "on")

    init = (e) ->
      return  if e.type is "readystatechange" and doc.readyState isnt "complete"
      (if e.type is "load" then win else doc)[rem] pre + e.type, init, false
      unless done
        done = yes
        callback()

    poll = ->
      try
        root.doScroll "left"
      catch e
        setTimeout poll, 50
        return
      init "poll"

    unless doc.readyState is "complete"
      if doc.createEventObject and root.doScroll
        try
          top = not win.frameElement
        poll()  if top
      doc[add] pre + "DOMContentLoaded", init, false
      doc[add] pre + "readystatechange", init, false
      win[add] pre + "load", init, false


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
    if !element
      element = [ ]
    else if typeof element == "string"
      element = @find document.body, element
      element = if element then [ element ] else [ ]
    else if element instanceof NodeList
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
      @unwrap(element).getAttribute attr


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

  # Removes element
  remove: (element) ->
    element = @unwrap element
    parentNode = element.parentNode
    parentNode.removeChild element if parentNode?

  # Add a class
  addClass: (element, className) -> @unwrap(element).classList.add className

  # Remove a class
  removeClass: (element, className) -> @unwrap(element).classList.remove className

  # Set given css properties
  css: (element, properties) ->
    element = @unwrap @wrap element
    for own key, value of properties
      element.style[key] = value

  # Returns an object with given dimensions
  dimensions: (element) ->
    element = @unwrap @wrap element
    dimensions =
      width: element.offsetWidth
      height: element.offsetHeight

    unless dimensions.width and dimensions.height
      # The element is probably invisible. So make it visible
      revert =
        position: element.style.position || ''
        visibility: element.style.visibility || ''
        display: element.style.display || ''

      @css element,
        position: "absolute"
        visibility: "hidden"
        display: "block"

      dimensions =
        width: element.offsetWidth
        height: element.offsetHeight

      @css element, revert      

    dimensions

  # Returns the scroll offsets of current document
  scrollOffset: ->
    [
      window.pageXOffset or document.documentElement.scrollLeft or document.body.scrollLeft
      window.pageYOffset or document.documentElement.scrollTop or document.body.scrollTop
    ]

  # Returns the dimensions of the viewport (currently visible browser area)
  viewportDimensions: ->
    {
      width: document.documentElement.clientWidth
      height: document.documentElement.clientHeight
    }

  # Returns an object with x and y 
  mousePosition: (e) ->
    pos = x: 0, y: 0

    e ?= window.event

    return unless e?

    try
      if e.pageX or e.pageY
        pos.x = e.pageX
        pos.y = e.pageY
      else if e.clientX or e.clientY
        pos.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
        pos.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop
    catch e
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
  observe: (element, eventName, observer) ->
    # Firefox <= 3.6 needs the last optional parameter `useCapture`
    @unwrap(element).addEventListener eventName, observer, false

  # Stop observing event
  stopObserving: (element, eventName, observer) ->
    # Firefox <= 3.6 needs the last optional parameter `useCapture`
    @unwrap(element).removeEventListener eventName, observer, false


  # Perform an AJAX request and call the appropriate callbacks.
  ajax: (options) ->
    throw new Error "No url provided" unless options.url?

    if window.XMLHttpRequest
      # Mozilla, Safari, ...
      request = new XMLHttpRequest
    else if window.ActiveXObject
      # IE
      try
        request = new ActiveXObject "Msxml2.XMLHTTP"
      catch e
        try
          request = new ActiveXObject "Microsoft.XMLHTTP"
        catch e

    throw new Error "Can't create XMLHttpRequest" unless request

    request.onreadystatechange = ->
      if request.readyState == 4
        try
          if request.status == 200
            options.onSuccess? request.responseText
          else
            options.onError? "Server responded with status #{request.status}"
        catch e
          options.onError? e.message

        options.onComplete?()


    request.open options.method?.toUpperCase() ? "GET", options.url
    request.send()

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






# Add the adapter to the list
Opentip.addAdapter new Adapter
