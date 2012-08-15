
$ = ender


class Adapter

  # Simply using $.domReady
  domReady: $.domReady.apply $, arguments


  # Using bonzo to create html
  create: (html) -> $ html

  # Mimics scriptaculous Builder.node behaviour
  # element: (tagName, attributes, children) ->
  #   if Object.isArray(attributes) or Object.isString(attributes) or Object.isElement(attributes)
  #     children = attributes
  #     attributes = null
  #   element = new Element(tagName, attributes or {})
    
  #   # This is a prototype 1.6 bug, that doesn't apply the className to IE8 elements.
  #   # Thanks to Alexander Shakhnovsky for finding the bug, and pinpointing the problem.
  #   if attributes and attributes["className"]
  #     attributes["className"].split(" ").each (class_name) ->
  #       element.addClassName class_name

  #   if children
  #     if Object.isArray(children)
  #       children.each (child) ->
  #         element.insert bottom: child

  #     else
  #       element.insert bottom: children
  #   element



adapter = new Adapter

Opentip.adapters.ender = adapter
Opentip.adapter = adapter