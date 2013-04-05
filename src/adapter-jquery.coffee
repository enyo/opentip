# jQuery Opentip Adapter
# ======================
#
# Uses jQuery

# Because $ is my favorite character
(($) ->


  # Augment jQuery
  $.fn.opentip = (content, title, options) ->
    new Opentip this, content, title, options


  # And now the class
  class Adapter

    name: "jquery"

    # Simply using $.domReady
    domReady: (callback) -> $ callback


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

    # Returns the unwrapped element
    unwrap: (element) -> $(element)[0]

    # Returns the tag name of the element
    tagName: (element) -> @unwrap(element).tagName

    # Returns or sets the given attribute of element
    #
    # It's important not to simply forward name and value because the value
    # is set whether or not the value argument is present
    attr: (element, args...) -> $(element).attr args...

    # Returns or sets the given data of element
    # It's important not to simply forward name and value because the value
    # is set whether or not the value argument is present
    data: (element, args...) -> $(element).data args...

    # Finds elements by selector
    find: (element, selector) -> $(element).find(selector).get(0)

    # Finds all elements by selector
    findAll: (element, selector) -> $(element).find selector

    # Updates the content of the element
    update: (element, content, escape) ->
      element = $ element
      if escape
        element.text content
      else
        element.html content

    # Appends given child to element
    append: (element, child) -> $(element).append child

    # Removes element
    remove: (element) -> $(element).remove()

    # Add a class
    addClass: (element, className) -> $(element).addClass className

    # Remove a class
    removeClass: (element, className) -> $(element).removeClass className

    # Set given css properties
    css: (element, properties) -> $(element).css properties

    # Returns an object with given dimensions
    dimensions: (element) ->
      {
        width: $(element).outerWidth()
        height: $(element).outerHeight()
      }

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
      return null unless e?
      x: e.pageX, y: e.pageY


    # Returns the offset of the element
    offset: (element) ->
      offset = $(element).offset()
      {
        left: offset.left
        top: offset.top
      }

    # Observe given eventName
    observe: (element, eventName, observer) -> $(element).bind eventName, observer

    # Stop observing event
    stopObserving: (element, eventName, observer) -> $(element).unbind eventName, observer

    # Perform an AJAX request and call the appropriate callbacks.
    ajax: (options) ->
      throw new Error "No url provided" unless options.url?
      $.ajax(
        url: options.url
        type: options.method?.toUpperCase() ? "GET"
      )
        .done((content) -> options.onSuccess? content)
        .fail((request) -> options.onError? "Server responded with status #{request.status}")
        .always(-> options.onComplete?())


    # Utility functions
    # =================

    # Creates a shallow copy of the object
    clone: (object) -> $.extend { }, object

    # Copies all properties from sources to target
    extend: (target, sources...) -> $.extend target, sources...

  # Add the adapter to the list
  Opentip.addAdapter new Adapter

)(jQuery)
