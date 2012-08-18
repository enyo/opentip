
# Native Opentip Adapter
# ======================
#
# Use this adapter if you don't use a framework like jQuery and you don't
# really care about oldschool browser compatibility.
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





# Create the adapter
adapter = new Adapter

# Add the adapter to the list
Opentip.adapters.native = adapter
# Set as adapter in use
Opentip.adapter = adapter
