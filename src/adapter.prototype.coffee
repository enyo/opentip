# Prototype Opentip Adapter
# ======================
#
# Uses the prototype framework

do ->

  Element.addMethods
    addTip: (element, content, title, options) ->
      new Opentip element, content, title, options


  # Needs this function because of IE8
  isArrayOrNodeList = (element) ->
    if (element instanceof Array) or (element? and typeof element.length == 'number' and typeof element.item == 'function' and typeof element.nextNode == 'function' and typeof element.reset == 'function')
      return yes
    return no

  # And now the class
  class Adapter

    name: "prototype"

    domReady: (callback) ->
      if document.loaded
        callback()
      else
        $(document).observe "dom:loaded", callback


    # DOM
    # ===

    # Using bonzo to create html
    create: (html) -> new Element('div').update(html).childElements()


    # Element handling
    # ----------------

    # Wraps the element
    wrap: (element) ->
      if isArrayOrNodeList element
        throw new Error "Multiple elements provided." if element.length > 1
        element = @unwrap element
      else if typeof element == "string"
        element = $$(element)[0]
      $ element

    # Returns the unwrapped element
    unwrap: (element) ->
      if isArrayOrNodeList element
        element[0]
      else
        element

    # Returns the tag name of the element
    tagName: (element) -> @unwrap(element).tagName

    # Returns or sets the given attribute of element
    #
    # It's important not to simply forward name and value because the value
    # is set whether or not the value argument is present
    attr: (element, args...) ->
      if args.length == 1
        @wrap(element).readAttribute args[0]
      else
        @wrap(element).writeAttribute args...

    # Returns or sets the given data of element
    # It's important not to simply forward name and value because the value
    # is set whether or not the value argument is present
    data: (element, name, value) ->
      @wrap(element)
      if arguments.length > 2
        element.store name, value
      else
        arg = element.readAttribute "data-#{name.underscore().dasherize()}"
        return arg if arg?
        element.retrieve name

    # Finds elements by selector
    find: (element, selector) -> @wrap(element).select(selector)[0]

    # Finds all elements by selector
    findAll: (element, selector) -> @wrap(element).select selector

    # Updates the content of the element
    update: (element, content, escape) ->
      @wrap(element).update if escape then content.escapeHTML() else content

    # Appends given child to element
    append: (element, child) -> @wrap(element).insert @wrap child

    # Removes element
    remove: (element) -> @wrap(element).remove()

    # Add a class
    addClass: (element, className) -> @wrap(element).addClassName className

    # Remove a class
    removeClass: (element, className) -> @wrap(element).removeClassName className

    # Set given css properties
    css: (element, properties) -> @wrap(element).setStyle properties

    # Returns an object with given dimensions
    dimensions: (element) -> @wrap(element).getDimensions()

    # Returns the scroll offsets of current document
    scrollOffset: ->
      offsets = document.viewport.getScrollOffsets()
      [ offsets.left, offsets.top ]

    # Returns the dimensions of the viewport (currently visible browser area)
    viewportDimensions: -> document.viewport.getDimensions()

    # Returns an object with x and y 
    mousePosition: (e) ->
      return null unless e?
      x: Event.pointerX(e), y: Event.pointerY(e)


    # Returns the offset of the element
    offset: (element) -> 
      offset = @wrap(element).cumulativeOffset()
      left: offset.left, top: offset.top

    # Observe given eventName
    observe: (element, eventName, observer) -> Event.observe @wrap(element), eventName, observer

    # Stop observing event
    stopObserving: (element, eventName, observer) -> Event.stopObserving @wrap(element), eventName, observer

    # Perform an AJAX request and call the appropriate callbacks.
    ajax: (options) ->
      throw new Error "No url provided" unless options.url?

      new Ajax.Request options.url, {
        method: options.method?.toUpperCase() ? "GET"
        onSuccess: (response) -> options.onSuccess? response.responseText
        onFailure: (response) -> options.onError? "Server responded with status #{response.status}"
        onComplete: -> options.onComplete?()
      }


    # Utility functions
    # =================

    # Creates a shallow copy of the object
    clone: (object) -> Object.clone(object)

    # Copies all properties from sources to target
    extend: (target, sources...) ->
      for source in sources
        Object.extend target, source
      target

  # Add the adapter to the list
  Opentip.addAdapter new Adapter

