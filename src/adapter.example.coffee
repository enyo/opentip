

class Adapter

  # Invoke callback as soon as dom is ready
  domReady: (callback) -> callback()

  # Create the HTML passed as string
  create: (html) -> html

  # Wrap the element in the framework
  wrap: (element) -> element

  # Creates a shallow copy of the object
  clone: (object) ->
    newObject = { }
    for own key, val of object
      newObject[key] = val
    newObject



adapter = new Adapter

Opentip.adapters.ender = adapter
Opentip.adapter = adapter