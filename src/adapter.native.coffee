

class Adapter

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
  wrap: (element) -> element

  # Returns the tag name of the element
  tagName: (element) -> element.tagName

  # Returns the given attribute of element
  attr: (element, attr) ->
    result = element.getAttribute?(attr)


  # Utility functions
  # =================

  # Creates a shallow copy of the object
  clone: (object) ->
    newObject = { }
    for own key, val of object
      newObject[key] = val
    newObject





adapter = new Adapter

Opentip.adapters.native = adapter
Opentip.adapter = adapter