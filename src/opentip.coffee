###
More info at http://www.opentip.org

Copyright (c) 2012, Matias Meno
Graphics by Tjandra Mayerhold

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
###

###
Usage:

<div data-ot="This will be viewed in tooltip"></div>

or externally:

$('elementId').addTip('Content', { options });

For a full documentation, please visit http://www.opentip.org/documentation
###

###
Namespace and helper functions for opentips.
###
Opentip =
  version: "2.0.0-dev"
  REQUIRED_PROTOTYPE_VERSION: "1.6.0"
  REQUIRED_SCRIPTACULOUS_VERSION: "1.8.0"
  STICKS_OUT_TOP: 1
  STICKS_OUT_BOTTOM: 2
  STICKS_OUT_LEFT: 1
  STICKS_OUT_RIGHT: 2
  cached: {}
  debugging: false
  load: ->
    getComparableVersion = (version) ->
      v = version.split(".")
      parseInt(v[0]) * 100000 + parseInt(v[1]) * 1000 + parseInt(v[2])
    throw ("Opentip requires the Prototype JavaScript framework >= " + Opentip.REQUIRED_PROTOTYPE_VERSION)  if (typeof Prototype is "undefined") or (typeof Element is "undefined") or (typeof Element.Methods is "undefined") or (getComparableVersion(Prototype.Version) < getComparableVersion(Opentip.REQUIRED_PROTOTYPE_VERSION))
    Opentip.useCss3Transitions = Opentip.supports("transition")
    Opentip.useScriptaculousTransitions = not Opentip.useCss3Transitions
    Opentip.debug "Using CSS3 transitions."  if Opentip.useCss3Transitions
    if (typeof Scriptaculous is "undefined") or (typeof Effect is "undefined") or (getComparableVersion(Scriptaculous.Version) < getComparableVersion(Opentip.REQUIRED_SCRIPTACULOUS_VERSION))
      Opentip.debug "No scriptaculous available. Disabling scriptaculous transitions."
      Opentip.useScriptaculousTransitions = false

  debug: ->
    console.debug.apply console, arguments  if @debugging and typeof console isnt "undefined" and typeof console.debug isnt "undefined"

  IEVersion: ->
    return Opentip.cached.IEVersion  if typeof Opentip.cached.IEVersion isnt "undefined"
    if Prototype.Browser.IE
      version = navigator.userAgent.match("MSIE ([\\d.]+)")
      IEVersion = (if version then (parseFloat(version[1])) else false)
    else
      IEVersion = false
    Opentip.cached.IEVersion = IEVersion
    IEVersion

  objectIsEvent: (obj) ->
    
    # There must be a better way of doing this.
    typeof (obj) is "object" and obj.type and obj.screenX

  useIFrame: ->
    (if Opentip.IEVersion() then (Opentip.IEVersion() <= 6) else false)

  lastTipId: 1
  lastZIndex: 100
  documentIsLoaded: false
  postponeCreation: (createFunction) ->
    Event.observe window, "load", createFunction  unless Opentip.documentIsLoaded or not Opentip.IEVersion() # Sorry IE users but... well: get another browser!

  
  # Mimics scriptaculous Builder.node behaviour
  element: (tagName, attributes, children) ->
    if Object.isArray(attributes) or Object.isString(attributes) or Object.isElement(attributes)
      children = attributes
      attributes = null
    element = new Element(tagName, attributes or {})
    
    # This is a prototype 1.6 bug, that doesn't apply the className to IE8 elements.
    # Thanks to Alexander Shakhnovsky for finding the bug, and pinpointing the problem.
    if attributes and attributes["className"]
      attributes["className"].split(" ").each (class_name) ->
        element.addClassName class_name

    if children
      if Object.isArray(children)
        children.each (child) ->
          element.insert bottom: child

      else
        element.insert bottom: children
    element

  
  # In the future every position attribute will go through this method.
  sanitizePosition: (arrayPosition) ->
    position = undefined
    if Object.isArray(arrayPosition)
      positionString = ""
      if arrayPosition[0] is "center"
        positionString = arrayPosition[1]
      else if arrayPosition[1] is "middle"
        positionString = arrayPosition[0]
      else
        positionString = arrayPosition[1] + arrayPosition[0].capitalize()
      throw "Unknown position: " + positionString  if Opentip.position[positionString] is `undefined`
      position = Opentip.position[positionString]
    else if Object.isString(arrayPosition)
      throw "Unknown position: " + arrayPosition  if Opentip.position[arrayPosition] is `undefined`
      position = Opentip.position[arrayPosition]
    parseInt position

  
  # Browser support testing 
  vendors: "Khtml Ms O Moz Webkit".split(" ")
  testDiv: document.createElement("div")
  supports: (prop) ->
    return true  if prop of Opentip.testDiv.style
    prop = prop.ot_ucfirst()
    Opentip.vendors.any (vendor) ->
      vendor + prop of Opentip.testDiv.style


String::ot_ucfirst = ->
  @replace /^\w/, (val) ->
    val.toUpperCase()


Opentip.load()

###
The standard style.
###
Opentip.styles =
  standard:
    
    # This style contains all default values for other styles.
    # POSITION : [ 'left|right|center', 'top|bottom|middle' ]
    # COORDINATE : [ XVALUE, YVALUE ] (integers)
    title: null
    className: "standard" # The class name to be used in the stylesheet
    stem: false # false (no stem)   ||   true (stem at tipJoint position)   ||   POSITION (for stems in other directions)
    delay: null # float (in seconds - if null, the default is used: 0.2 for mouseover, 0 for click)
    hideDelay: 0.1 # --
    fixed: false # If target is not null, elements are always fixed.
    showOn: "mouseover" # string (the observe string of the trigger element, eg: click, mouseover, etc..)   ||   'creation' (the tooltip will show when being created)   ||   null if you want to handle it yourself.
    hideTrigger: "trigger" # 'trigger' | 'tip' | 'target' | 'closeButton' | ELEMENT | ELEMENT_ID      ||      array containing any of the previous
    hideOn: null # string (event eg: click)   ||   array of event strings if multiple hideTriggers     ||    null (let Opentip decide)
    offset: [ 0, 0 ] # COORDINATE
    containInViewport: true # Whether the targetJoint/tipJoint should be changed if the tooltip is not in the viewport anymore.
    autoOffset: true # If set to true, offsets are calculated automatically to position the tooltip. (pixels are added if there are stems for example)
    showEffect: "appear" # scriptaculous or CSS3 (in opentip.css) effect
    fallbackShowEffect: "appear" # At tip creation, this effect will override the showEffect, if useScriptaculousTransitions == true, and the showEffect does not exist.
    hideEffect: "fade"
    fallbackHideEffect: "appear"
    showEffectDuration: 0.3
    hideEffectDuration: 0.2
    stemSize: 8 # integer
    tipJoint: [ "left", "top" ] # POSITION
    target: null # null (no target, opentip uses mouse as target)   ||   true (target is the triggerElement)   ||   elementId|element (for another element)
    targetJoint: null # POSITION (Ignored if target == null)   ||   null (targetJoint is the opposite of tipJoint)
    ajax: false # Ajax options. eg: { url: 'yourUrl.html', options: { ajaxOptions... } } or { options: { ajaxOptions } /* This will use the href of the A element the tooltip is attached to */ }
    group: null # You can group opentips together. So when a tooltip shows, it looks if there are others in the same group, and hides them.
    escapeHtml: false
    style: null

  slick:
    className: "slick"
    stem: true

  rounded:
    className: "rounded"
    stem: true

  glass:
    className: "glass"

Opentip.defaultStyle = "standard" # Change this to the style name you want your tooltips to have.
Opentip.position =
  top: 0
  topRight: 1
  right: 2
  bottomRight: 3
  bottom: 4
  bottomLeft: 5
  left: 6
  topLeft: 7


###
On document load
###
Event.observe window, (if Opentip.IEVersion() then "load" else "dom:loaded"), ->
  Opentip.documentIsLoaded = true
  htmlOptionNames = []
  for i of Opentip.styles.standard
    htmlOptionNames.push i.underscore().dasherize()
  
  # Go through all elements, and look for elements that have inline element
  # opentip definitions.
  $$("[data-ot]").each (element) ->
    options = {}
    element = $(element)
    content = element.readAttribute("data-ot")
    if content is "" or content is "true" or content is "yes"
      content = element.readAttribute("title")
      element.title = ""
    content or (content = "")
    htmlOptionNames.each (optionName) ->
      optionValue = undefined
      if optionValue = element.readAttribute("data-ot-" + optionName)
        try
          
          # See if it's a JSON string.
          optionValue = optionValue.gsub("'", "\"").evalJSON()
        
        # Well, it's not.
        options[optionName.camelize()] = optionValue

    element.addTip content, options


Tips =
  list: []
  append: (tip) ->
    @list.push tip

  remove: (element) ->
    unless element.element
      tip = @list.find((t) ->
        t.triggerElement is element
      )
    else
      tip = @list.find((t) ->
        t is element
      )
    if tip
      tip.deactivate()
      tip.destroyAllElements()
      @list = @list.without(tip)

  add: (element) ->
    if element._opentipAddedTips
      
      # TODO: Now it just returns the first found... try to find the correct one. 
      tip = @list.find((t) ->
        t.triggerElement is element
      )
      tip.show()  if tip.options.showOn is "creation"
      tip.debug "Using an existing opentip."
      return
    else # I added a timeout, so that tooltips, defined in an onmouseover or onclick event, will show.
      setTimeout (->
        element._opentipAddedTips = true
      ), 1
    Opentip.debug "Creating new opentip"
    tipArguments = []
    $A(arguments).each (arg, idx) ->
      tipArguments.push null  if idx is 1 and not Opentip.objectIsEvent(arg)
      tipArguments.push arg

    
    # Creating the tooltip object, but not yet activating it, or creating the container elements.
    tooltip = new TipClass(tipArguments[0], tipArguments[1], tipArguments[2], tipArguments[3], tipArguments[4])
    @append tooltip
    self = this
    createTip = ->
      tooltip.create tipArguments[1] # Passing the event.

    Opentip.postponeCreation createTip
    tooltip

  hideGroup: (groupName) ->
    @list.findAll((t) ->
      t.options.group is groupName
    ).invoke "doHide"

  abortShowingGroup: (groupName) ->
    @list.findAll((t) ->
      t.options.group is groupName
    ).invoke "abortShowing"

Tip = ->
  Tips.add.apply Tips, arguments

Element.addMethods
  addTip: (element) ->
    element = $(element)
    Tips.add.apply Tips, arguments
    element

  setCss3Style: (element) ->
    element = $(element)
    style = {}
    for propertyName of arguments[1]
      css3PropertyName = propertyName.ot_ucfirst()
      css3PropertyValue = arguments[1][propertyName]
      Opentip.vendors.each (vendor) ->
        style[vendor + css3PropertyName] = css3PropertyValue
        element.setStyle style

    element

TipClass = Class.create(
  debug: ->
    newArguments = Array.from(arguments)
    newArguments.unshift "ID:", @id, "|"
    Opentip.debug.apply Opentip, newArguments

  initialize: (element, evt) ->
    @id = Opentip.lastTipId++
    element = $(element)
    @triggerElement = element
    @loaded = false # for ajax
    @loading = false # for ajax
    @visible = false
    @waitingToShow = false
    @waitingToHide = false
    @lastPosition =
      left: 0
      top: 0

    @dimensions = [ 100, 50 ] # Just some initial values.
    options = {}
    @content = ""
    if typeof (arguments[2]) is "object"
      options = Object.clone(arguments[2])
    else if typeof (arguments[3]) is "object"
      @setContent arguments[2]
      options = Object.clone(arguments[3])
    else if typeof (arguments[4]) is "object"
      @setContent arguments[2]
      options = Object.clone(arguments[4])
      options.title = arguments[3]
    else
      @setContent arguments[2]  if Object.isString(arguments[2]) or Object.isFunction(arguments[2])
      options.title = arguments[3]  if Object.isString(arguments[3])
    
    # Use the type of the html event (eg: onclick="") if called in an event.
    options.showOn = evt.type  if not options.showOn and evt
    
    # If the url of an Ajax request is not set, get it from the link it's attached to.
    if options.ajax and not options.ajax.url
      if @triggerElement.tagName.toLowerCase() is "a"
        options.ajax = {}  unless typeof (options.ajax) is "object"
        options.ajax.url = @triggerElement.href
      else
        options.ajax = false
    
    # If the event is 'click', no point in following a link
    if options.showOn is "click" and @triggerElement.tagName.toLowerCase() is "a"
      evt.stop()  if evt
      @triggerElement.observe "click", (e) ->
        e.stop()

    options.style or (options.style = Opentip.defaultStyle)
    styleOptions = Object.extend({}, Opentip.styles.standard) # Copy all standard options.
    Object.extend styleOptions, Opentip.styles[options.style]  unless options.style is "standard"
    options = Object.extend(styleOptions, options)
    options.target and (options.fixed = true)
    options.stem = options.tipJoint  if options.stem is true
    if options.target is true
      options.target = @triggerElement
    else options.target = $(options.target)  if options.target
    @currentStemPosition = options.stem
    if options.delay is null
      if options.showOn is "mouseover"
        options.delay = 0.2
      else
        options.delay = 0
    if Opentip.useScriptaculousTransitions
      if options.showEffect and not Effect[options.showEffect.ot_ucfirst()]
        @debug "Using fallback show effect \"" + options.fallbackShowEffect + "\" instead of \"" + options.showEffect + "\""
        options.showEffect = options.fallbackShowEffect
      if options.hideEffect and not Effect[options.hideEffect.ot_ucfirst()]
        @debug "Using fallback hide effect \"" + options.fallbackHideEffect + "\" instead of \"" + options.hideEffect + "\""
        options.hideEffect = options.fallbackHideEffect
    unless options.targetJoint?
      options.targetJoint = []
      options.targetJoint[0] = (if options.tipJoint[0] is "left" then "right" else ((if options.tipJoint[0] is "right" then "left" else "center")))
      options.targetJoint[1] = (if options.tipJoint[1] is "top" then "bottom" else ((if options.tipJoint[1] is "bottom" then "top" else "middle")))
    @options = options
    @options.showTriggerElementsWhenHidden = []
    if @options.showOn and @options.showOn isnt "creation"
      @options.showTriggerElementsWhenHidden.push
        element: @triggerElement
        event: @options.showOn

    @options.showTriggerElementsWhenVisible = []
    @options.hideTriggerElements = []

  
  ###
  This builds the container, and sets the correct hide trigger.
  Since it's a problem for IE to create elements when the page is not fully
  loaded, this function has to be posponed until the website is fully loaded.
  
  This function also activates the tooltip.
  ###
  create: (evt) ->
    @buildContainer()
    if @options.hideTrigger
      hideOnEvent = null
      hideTriggerElement = null
      @options.hideTrigger = [ @options.hideTrigger ]  unless @options.hideTrigger instanceof Array
      
      # When the hide trigger is mouseout, we have to attach a mouseover trigger to that element, so the tooltip doesn't disappear when
      # hovering child elements. (Hovering children fires a mouseout mouseover event)
      @options.hideTrigger.each (hideTrigger, i) ->
        hideOnOption = (if (@options.hideOn instanceof Array) then @options.hideOn[i] else @options.hideOn)
        switch hideTrigger
          when "trigger"
            hideOnEvent = (if hideOnOption then hideOnOption else "mouseout")
            hideTriggerElement = @triggerElement
          when "tip"
            hideOnEvent = (if hideOnOption then hideOnOption else "mouseover")
            hideTriggerElement = @container
          when "target"
            hideOnEvent = (if hideOnOption then hideOnOption else "mouseover")
            hideTriggerElement = @options.target
          when "closeButton"
          else
            hideOnEvent = (if hideOnOption then hideOnOption else "mouseover")
            hideTriggerElement = $(hideTrigger)
        if hideTriggerElement
          @options.hideTriggerElements.push
            element: hideTriggerElement
            event: hideOnEvent

          if hideOnEvent is "mouseout"
            @options.showTriggerElementsWhenVisible.push
              element: hideTriggerElement
              event: "mouseover"

      .bind(this)
    @activate()
    @show evt  if evt or @options.showOn is "creation"

  activate: ->
    @bound = {}
    @bound.doShow = @doShow.bindAsEventListener(this)
    @bound.show = @show.bindAsEventListener(this)
    @bound.doHide = @doHide.bindAsEventListener(this)
    @bound.hide = @hide.bindAsEventListener(this)
    @bound.position = @position.bindAsEventListener(this)
    if @options.showEffect or @options.hideEffect
      @queue =
        limit: 1
        position: "end"
        scope: @container.identify()
    
    # The order is important here! Do not reverse.
    @setupObserversForReallyHiddenTip()
    @setupObserversForHiddenTip()

  deactivate: ->
    @debug "Deactivating tooltip."
    @doHide()
    @setupObserversForReallyHiddenTip()

  buildContainer: ->
    @container = $(Opentip.element("div",
      className: "ot-container ot-completely-hidden style-" + @options.className + ((if @options.ajax then " ot-loading" else "")) + ((if @options.fixed then " ot-fixed" else ""))
    ))
    if Opentip.useCss3Transitions
      @container.setCss3Style transitionDuration: "0s" # To make sure the initial state doesn't fade
      @container.addClassName "ot-css3"
      @container.addClassName "ot-show-" + @options.showEffect  if @options.showEffect
      @container.addClassName "ot-hide-" + @options.hideEffect  if @options.hideEffect
    @container.setStyle display: "none"  if Opentip.useScriptaculousTransitions

  buildElements: ->
    stemCanvas = undefined
    closeButtonCanvas = undefined
    if @options.stem
      stemOffset = "-" + @options.stemSize + "px"
      @container.appendChild Opentip.element("div",
        className: "stem-container " + @options.stem[0] + " " + @options.stem[1]
      , stemCanvas = Opentip.element("canvas",
        className: "stem"
      ))
    self = this
    content = []
    headerContent = []
    if @options.title
      headerContent.push Opentip.element("div",
        className: "title"
      , @options.title)
    content.push Opentip.element("div",
      className: "header"
    , headerContent)
    content.push $(Opentip.element("div", # Will be updated by updateElementContent()
      className: "content"
    ))
    if @options.ajax
      content.push $(Opentip.element("div",
        className: "loadingIndication"
      , Opentip.element("span", "Loading...")))
    @tooltipElement = $(Opentip.element("div",
      className: "opentip"
    , content))
    @container.appendChild @tooltipElement
    buttons = @container.appendChild(Opentip.element("div",
      className: "ot-buttons"
    ))
    drawCloseButton = false
    if @options.hideTrigger and @options.hideTrigger.include("closeButton")
      buttons.appendChild Opentip.element("a",
        href: "javascript:undefined"
        className: "close"
      , closeButtonCanvas = Opentip.element("canvas",
        className: "canvas"
      ))
      
      # The canvas has to have a className assigned, because IE < 9 doesn't know the element, and won't assign any css to it.
      drawCloseButton = true
    if Opentip.useIFrame()
      @iFrameElement = @container.appendChild($(Opentip.element("iframe",
        className: "opentipIFrame"
        src: "javascript:false;"
      )).setStyle(
        display: "none"
        zIndex: 100
      ).setOpacity(0))
    document.body.appendChild @container
    if typeof G_vmlCanvasManager isnt "undefined"
      G_vmlCanvasManager.initElement stemCanvas  if stemCanvas
      G_vmlCanvasManager.initElement closeButtonCanvas  if closeButtonCanvas
    @drawCloseButton()  if drawCloseButton

  drawCloseButton: ->
    canvasElement = @container.down(".ot-buttons canvas")
    containerElement = @container.down(".ot-buttons .close")
    size = parseInt(containerElement.getStyle("width")) or 20 # Opera 10 has a bug here.. it seems to never get the width right.
    crossColor = canvasElement.getStyle("color")
    crossColor = "white"  if not crossColor or crossColor is "transparent"
    backgroundColor = canvasElement.getStyle("backgroundColor")
    backgroundColor = "rgba(0, 0, 0, 0.2)"  if not backgroundColor or backgroundColor is "transparent"
    canvasElement.setStyle backgroundColor: "transparent"
    canvasElement.width = size
    canvasElement.height = size
    ctx = canvasElement.getContext("2d")
    ctx.clearRect 0, 0, size, size
    ctx.beginPath()
    padding = size / 2.95
    ctx.fillStyle = backgroundColor
    ctx.lineWidth = size / 5.26
    ctx.strokeStyle = crossColor
    ctx.lineCap = "round"
    ctx.arc size / 2, size / 2, size / 2, 0, Math.PI * 2, false
    ctx.fill()
    ctx.beginPath()
    ctx.moveTo padding, padding
    ctx.lineTo size - padding, size - padding
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo size - padding, padding
    ctx.lineTo padding, size - padding
    ctx.stroke()

  
  ###
  Sets the content of the tooltip.
  This can be a function or a string. The function will be executed, and the
  result used as new content of the tooltip.
  
  If the tooltip is visible, this function calls updateElementContent()
  ###
  setContent: (content) ->
    @content = content
    @updateElementContent()  if @visible

  
  ###
  Actually updates the html element with the content.
  This function also evaluates the content function, if content is a function.
  ###
  updateElementContent: ->
    contentDiv = @container.down(".content")
    if contentDiv
      if Object.isFunction(@content)
        @debug "Executing content function."
        @content = @content(this)
      contentDiv.update (if @options.escapeHtml then @content.escapeHTML() else @content)
    @storeAndFixDimensions()

  storeAndFixDimensions: ->
    @container.setStyle
      width: "auto"
      left: "0px"
      top: "0px"

    @dimensions = @container.getDimensions()
    @container.setStyle
      width: @dimensions.width + "px"
      left: @lastPosition.left + "px"
      top: @lastPosition.top + "px"


  destroyAllElements: ->
    @container.remove()  if @container

  clearShowTimeout: ->
    window.clearTimeout @timeoutId

  clearHideTimeout: ->
    window.clearTimeout @hideTimeoutId

  clearTimeouts: ->
    window.clearTimeout @visibilityStateTimeoutId
    @clearShowTimeout()
    @clearHideTimeout()

  
  ###
  Gets called only when doShow() is called, not when show() is called *
  ###
  setupObserversForReallyVisibleTip: ->
    @options.showTriggerElementsWhenVisible.each ((pair) ->
      $(pair.element).observe pair.event, @bound.show
    ), this

  
  ###
  Gets only called when show() is called. show() might not really result in showing the tooltip, because there may
  be another trigger that calls hide() directly after. *
  ###
  setupObserversForVisibleTip: ->
    @options.hideTriggerElements.each ((pair) ->
      $(pair.element).observe pair.event, @bound.hide
    ), this
    @options.showTriggerElementsWhenHidden.each ((pair) ->
      $(pair.element).stopObserving pair.event, @bound.show
    ), this
    Event.observe (if document.onresize then document else window), "resize", @bound.position
    Event.observe window, "scroll", @bound.position

  
  ###
  Gets called only when doHide() is called.
  ###
  setupObserversForReallyHiddenTip: ->
    @options.showTriggerElementsWhenVisible.each ((pair) ->
      $(pair.element).stopObserving pair.event, @bound.show
    ), this

  
  ###
  Gets called everytime hide() is called. See setupObserversForVisibleTip for more info *
  ###
  setupObserversForHiddenTip: ->
    @options.showTriggerElementsWhenHidden.each ((pair) ->
      $(pair.element).observe pair.event, @bound.show
    ), this
    @options.hideTriggerElements.each ((pair) ->
      $(pair.element).stopObserving pair.event, @bound.hide
    ), this
    Event.stopObserving (if document.onresize then document else window), "resize", @bound.position
    Event.stopObserving window, "scroll", @bound.position

  
  ###
  The show function only schedules the tooltip to show. (If there is a delay, this function will generate the timer)
  The actual function to show the tooltip is doShow().
  ###
  show: (evt) ->
    @abortHiding()
    return  if @visible
    @debug "Showing in " + @options.delay + "s."
    Tips.abortShowingGroup @options.group  if @options.group
    @waitingToShow = true
    
    # Even though it is not yet visible, I already attach the observers, so the tooltip won't show if a hideEvent is triggered.
    @setupObserversForVisibleTip()
    
    # So the tooltip is positioned as soon as it shows.
    @followMousePosition()
    @position evt
    unless @options.delay
      @bound.doShow evt
    else
      @timeoutId = @bound.doShow.delay(@options.delay)

  
  # If the tip is waiting to show (and only then), this will abort it.
  abortShowing: ->
    if @waitingToShow
      @debug "Aborting showing."
      @clearTimeouts()
      @stopFollowingMousePosition()
      @waitingToShow = false
      @setupObserversForHiddenTip()

  
  ###
  Actually shows the tooltip. This function is called when any possible delay has expired.
  ###
  doShow: ->
    @clearTimeouts()
    return  if @visible
    
    # Thanks to Torsten Saam for this enhancement.
    unless @triggerElementExists()
      @deactivate()
      return
    @debug "Showing!"
    Tips.hideGroup @options.group  if @options.group
    @visible = true
    @waitingToShow = false
    @buildElements()  unless @tooltipElement
    @updateElementContent()
    @loadAjax()  if @options.ajax and not @loaded
    @searchAndActivateHideButtons()
    @ensureElement()
    @container.setStyle zIndex: Opentip.lastZIndex += 1
    
    # The order is important here! Do not reverse.
    @setupObserversForReallyVisibleTip()
    @setupObserversForVisibleTip()
    if Opentip.useScriptaculousTransitions
      @cancelEffects()  if @options.showEffect or @options.hideEffect
      if not @options.showEffect or not @container[@options.showEffect]
        @container.show()
      else
        @container[@options.showEffect]
          duration: @options.showEffectDuration
          queue: @queue
          afterFinish: @afterShowEffect.bind(this)

      @iFrameElement.show()  if Opentip.useIFrame()
    @position()
    @container.removeClassName("ot-hidden").addClassName "ot-becoming-visible"
    
    ###
    The next lines may seem a bit weird. I ran into some bizarre opera problems
    while implementing the switch of the different states.
    
    This is what's happening here:
    
    I wanted to just remove ot-completely-hidden, and add ot-becoming-visible
    (so the tip has the style it should have when it appears) and then switch
    ot-becoming-visible with ot-visible so the transition can take place.
    I then setup a timer to set ot-completely-visible when appropriate.
    
    I ran into problems with opera, which showed the tip for a frame because
    apparently the -o-transforms are slower then just setting display: none
    (or something...)
    
    So I have to 1) set ot-becoming-visible first, so the tip has the appropriate
    CSS definitions set, 2) defer the removal of ot-completely-hidden, so it's
    not invisible anymore, and 3) defer the rest of the process (setting ot-visible
    and stuff) so the transition takes place.
    ###
    startShowEffect = ->
      @container.setCss3Style transitionDuration: @options.showEffectDuration + "s"  if Opentip.useCss3Transitions
      @container.removeClassName("ot-becoming-visible").addClassName "ot-visible"
      if @options.showEffect and @options.showEffectDuration
        @visibilityStateTimeoutId = (->
          @removeClassName("ot-visible").addClassName "ot-completely-visible"
        ).bind(@container).delay(@options.showEffectDuration)
      else
        @container.removeClassName("ot-visible").addClassName "ot-completely-visible"
      @activateFirstInput()

    # Has to be deferred, so the div has the class ot-becoming-visible.
    (->
      @container.removeClassName "ot-completely-hidden"
      (startShowEffect).bind(this).defer()
    ).bind(this).defer()

  loadAjax: ->
    return  if @loading
    @loading = true
    @container.addClassName "ot-loading"
    @debug "Loading content from " + @options.ajax.url + "."
    ajaxOptions = Object.extend(
      onComplete: ->
        @container.removeClassName "ot-loading"
        @loaded = true
        @loading = false
        @updateElementContent()
        @searchAndActivateHideButtons()
        @activateFirstInput()
        @position()
      .bind(this)
      onSuccess: (transport) ->
        @debug "Loading successfull."
        @content = transport.responseText
      .bind(this)
      onFailure: ->
        @debug "There was a problem downloading the file."
        @options.escapeHtml = false
        @content = "<a class=\"close\">There was a problem downloading the content.</a>"
      .bind(this)
      method: "get"
    , @options.ajax.options or {})
    new Ajax.Request(@options.ajax.url, ajaxOptions)

  afterShowEffect: ->
    @activateFirstInput()
    @position()

  activateFirstInput: ->
    
    # TODO: check if there is a simple way of finding EITHER an input OR a textarea.
    input = @container.down("input")
    textarea = @container.down("textarea")
    if input
      input.focus()
    else textarea.focus()  if textarea

  searchAndActivateHideButtons: ->
    if not @options.hideTrigger or @options.hideTrigger.include("closeButton")
      @options.hideTriggerElements = []
      @container.select(".close").each ((el) ->
        @options.hideTriggerElements.push
          element: el
          event: "click"

      ), this
      @setupObserversForVisibleTip()  if @visible

  hide: (afterFinish) ->
    @abortShowing()
    return  unless @visible
    @debug "Hiding in " + @options.hideDelay + "s."
    @waitingToHide = true
    
    # We start observing even though it is not yet hidden, so the tooltip does not disappear when a showEvent is triggered.
    @setupObserversForHiddenTip()
    @hideTimeoutId = @bound.doHide.delay(@options.hideDelay, afterFinish) # hide has to be delayed because when hovering children a mouseout is registered.

  abortHiding: ->
    if @waitingToHide
      @debug "Aborting hiding."
      @clearTimeouts()
      @waitingToHide = false
      @setupObserversForVisibleTip()

  doHide: (afterFinish) ->
    @clearTimeouts()
    return  unless @visible
    @debug "Hiding!"
    @visible = false
    @waitingToHide = false
    @deactivateElementEnsurance()
    
    # The order is important here! Do not reverse.
    @setupObserversForReallyHiddenTip()
    @setupObserversForHiddenTip()
    @stopFollowingMousePosition()  unless @options.fixed
    if Opentip.useScriptaculousTransitions
      @cancelEffects()  if @options.showEffect or @options.hideEffect
      unless not @options.hideEffect or not @container[@options.hideEffect]
        effectOptions =
          duration: @options.hideEffectDuration
          queue: @queue

        effectOptions.afterFinish = afterFinish  if afterFinish and Object.isFunction(afterFinish)
        @container[@options.hideEffect] effectOptions
      @iFrameElement.hide()  if Opentip.useIFrame()
    @container.setCss3Style transitionDuration: @options.hideEffectDuration + "s"  if Opentip.useCss3Transitions
    @container.removeClassName("ot-visible").removeClassName("ot-completely-visible").addClassName "ot-hidden"
    if @options.hideEffect and @options.hideEffectDuration
      @visibilityStateTimeoutId = (->
        @setCss3Style transitionDuration: "0s"
        @removeClassName("ot-hidden").addClassName "ot-completely-hidden"
      ).bind(@container).delay(@options.showEffectDuration)
    else
      @container.removeClassName("ot-hidden").addClassName "ot-completely-hidden"

  cancelEffects: ->
    Effect.Queues.get(@queue.scope).invoke "cancel"

  followMousePosition: ->
    $(document.body).observe "mousemove", @bound.position  unless @options.fixed

  stopFollowingMousePosition: ->
    $(document.body).stopObserving "mousemove", @bound.position  unless @options.fixed

  positionsEqual: (position1, position2) ->
    position1.left is position2.left and position1.top is position2.top

  position: (evt) ->
    evt = evt or @lastEvt
    @currentStemPosition = @options.stem # This gets reset by ensureViewportContainment if necessary.
    position = @ensureViewportContainment(evt, @getPosition(evt))
    if @positionsEqual(position, @lastPosition)
      @positionStem()
      return
    @lastPosition = position
    if position
      style =
        left: position.left + "px"
        top: position.top + "px"

      @container.setStyle style
      if Opentip.useIFrame() and @iFrameElement
        @iFrameElement.setStyle
          width: @container.getWidth() + "px"
          height: @container.getHeight() + "px"

      
      ###
      Following is a redraw fix, because I noticed some drawing errors in some browsers when tooltips where overlapping.
      ###
      container = @container
      # I chose visibility instead of display so that I don't interfere with appear/disappear effects.
      (->
        container.style.visibility = "hidden"
        redrawFix = container.offsetHeight
        container.style.visibility = "visible"
      ).defer()
    @positionStem()

  getPosition: (evt, tipJ, trgJ, stem) ->
    tipJ = tipJ or @options.tipJoint
    trgJ = trgJ or @options.targetJoint
    position = {}
    if @options.target
      tmp = @options.target.cumulativeOffset()
      position.left = tmp[0]
      position.top = tmp[1]
      if trgJ[0] is "right"
        
        # For wrapping inline elements, left + width does not give the right border, because left is where
        # the element started, not its most left position.
        unless typeof @options.target.getBoundingClientRect is "undefined"
          position.left = @options.target.getBoundingClientRect().right + $(document.viewport).getScrollOffsets().left
        else
          position.left = position.left + @options.target.getWidth()
      else position.left += Math.round(@options.target.getWidth() / 2)  if trgJ[0] is "center"
      if trgJ[1] is "bottom"
        position.top += @options.target.getHeight()
      else position.top += Math.round(@options.target.getHeight() / 2)  if trgJ[1] is "middle"
    else
      return  unless evt # No event passed, so returning.
      @lastEvt = evt
      position.left = Event.pointerX(evt)
      position.top = Event.pointerY(evt)
    if @options.autoOffset
      stemSize = (if @options.stem then @options.stemSize else 0)
      offsetDistance = (if (stemSize and @options.fixed) then 2 else 10) # If there is as stem offsets dont need to be that big if fixed.
      additionalHorizontal = (if (tipJ[1] is "middle" and not @options.fixed) then 15 else 0)
      additionalVertical = (if (tipJ[0] is "center" and not @options.fixed) then 15 else 0)
      if tipJ[0] is "right"
        position.left -= offsetDistance + additionalHorizontal
      else position.left += offsetDistance + additionalHorizontal  if tipJ[0] is "left"
      if tipJ[1] is "bottom"
        position.top -= offsetDistance + additionalVertical
      else position.top += offsetDistance + additionalVertical  if tipJ[1] is "top"
      if stemSize
        stem = stem or @options.stem
        if stem[0] is "right"
          position.left -= stemSize
        else position.left += stemSize  if stem[0] is "left"
        if stem[1] is "bottom"
          position.top -= stemSize
        else position.top += stemSize  if stem[1] is "top"
    position.left += @options.offset[0]
    position.top += @options.offset[1]
    position.left -= @container.getWidth()  if tipJ[0] is "right"
    position.left -= Math.round(@container.getWidth() / 2)  if tipJ[0] is "center"
    position.top -= @container.getHeight()  if tipJ[1] is "bottom"
    position.top -= Math.round(@container.getHeight() / 2)  if tipJ[1] is "middle"
    position

  ensureViewportContainment: (evt, position) ->
    
    # Sometimes the element is theoretically visible, but an effect is not yet showing it.
    # So the calculation of the offsets is incorrect sometimes, which results in faulty repositioning.
    return position  unless @visible
    sticksOut = [ @sticksOutX(position), @sticksOutY(position) ]
    return position  if not sticksOut[0] and not sticksOut[1]
    tipJ = @options.tipJoint.clone()
    trgJ = @options.targetJoint.clone()
    viewportScrollOffset = $(document.viewport).getScrollOffsets()
    dimensions = @dimensions
    viewportOffset =
      left: position.left - viewportScrollOffset.left
      top: position.top - viewportScrollOffset.top

    viewportDimensions = document.viewport.getDimensions()
    reposition = false
    if viewportDimensions.width >= dimensions.width
      if viewportOffset.left < 0
        reposition = true
        tipJ[0] = "left"
        trgJ[0] = "right"  if @options.target and trgJ[0] is "left"
      else if viewportOffset.left + dimensions.width > viewportDimensions.width
        reposition = true
        tipJ[0] = "right"
        trgJ[0] = "left"  if @options.target and trgJ[0] is "right"
    if viewportDimensions.height >= dimensions.height
      if viewportOffset.top < 0
        reposition = true
        tipJ[1] = "top"
        trgJ[1] = "bottom"  if @options.target and trgJ[1] is "top"
      else if viewportOffset.top + dimensions.height > viewportDimensions.height
        reposition = true
        tipJ[1] = "bottom"
        trgJ[1] = "top"  if @options.target and trgJ[1] is "bottom"
    if reposition
      newPosition = @getPosition(evt, tipJ, trgJ, tipJ)
      newSticksOut = [ @sticksOutX(newPosition), @sticksOutY(newPosition) ]
      revertedCount = 0
      i = 0

      while i <= 1
        if newSticksOut[i] and newSticksOut[i] isnt sticksOut[i]
          
          # The tooltip changed sides, but now is sticking out the other side of the window.
          # If its still sticking out, but on the same side, it's ok. At least, it sticks out less.
          revertedCount++
          tipJ[i] = @options.tipJoint[i]
          trgJ[i] = @options.targetJoint[i]  if @options.target
        i++
      if revertedCount < 2
        @currentStemPosition = tipJ
        return @getPosition(evt, tipJ, trgJ, tipJ)
    position

  sticksOut: (position) ->
    @sticksOutX(position) or @sticksOutY(position)

  
  ###
  return 1 for left 2 for right
  ###
  sticksOutX: (position) ->
    viewportScrollOffset = $(document.viewport).getScrollOffsets()
    viewportOffset =
      left: position.left - viewportScrollOffset.left
      top: position.top - viewportScrollOffset.top

    return Opentip.STICKS_OUT_LEFT  if viewportOffset.left < 0
    Opentip.STICKS_OUT_RIGHT  if viewportOffset.left + @dimensions.width > document.viewport.getDimensions().width

  
  ###
  return 1 for top 2 for bottom
  ###
  sticksOutY: (position) ->
    viewportScrollOffset = $(document.viewport).getScrollOffsets()
    viewportOffset =
      left: position.left - viewportScrollOffset.left
      top: position.top - viewportScrollOffset.top

    return Opentip.STICKS_OUT_TOP  if viewportOffset.top < 0
    Opentip.STICKS_OUT_BOTTOM  if viewportOffset.top + @dimensions.height > document.viewport.getDimensions().height

  getStemCanvas: ->
    @container.down ".stem"

  stemPositionsEqual: (position1, position2) ->
    position1 and position2 and position1[0] is position2[0] and position1[1] is position2[1]

  positionStem: ->
    
    # Position stem
    if @options.stem
      canvasElement = @getStemCanvas()
      if canvasElement and not @stemPositionsEqual(@lastStemPosition, @currentStemPosition)
        @debug "Setting stem style"
        @lastStemPosition = @currentStemPosition
        stemPosition = Opentip.sanitizePosition(@currentStemPosition)
        stemSize = @options.stemSize
        rotationRad = stemPosition * Math.PI / 4 # Every number means 45deg
        baseThikness = Math.round(stemSize * 1.5)
        realDim =
          w: baseThikness
          h: stemSize

        isCorner = false
        if stemPosition % 2 is 1
          
          # Corner
          isCorner = true
          additionalWidth = Math.round(0.707106781 * baseThikness) # 0.707106781 == sqrt(2) / 2 to calculate the adjacent leg of the triangle
          realDim =
            w: stemSize + additionalWidth
            h: stemSize + additionalWidth
        drawDim = Object.clone(realDim) # The drawDim is so that I can draw without takin the rotation into calculation
        if stemPosition is Opentip.position.left or stemPosition is Opentip.position.right
          
          # The canvas has to be rotated
          realDim.h = drawDim.w
          realDim.w = drawDim.h
        stemColor = canvasElement.getStyle("color") or "black"
        canvasElement.width = realDim.w
        canvasElement.height = realDim.h
        
        # Now draw the stem.
        ctx = canvasElement.getContext("2d")
        ctx.clearRect 0, 0, canvasElement.width, canvasElement.height
        ctx.beginPath()
        ctx.fillStyle = stemColor
        ctx.save()
        ctx.translate realDim.w / 2, realDim.h / 2
        rotations = Math.floor(stemPosition / 2)
        ctx.rotate rotations * Math.PI / 2
        if realDim.w is drawDim.w # This is a real hack because I don't know how to reset to 0,0
          ctx.translate -realDim.w / 2, -realDim.h / 2
        else
          ctx.translate -realDim.h / 2, -realDim.w / 2
        if isCorner
          ctx.moveTo additionalWidth, drawDim.h
          ctx.lineTo drawDim.w, 0
          ctx.lineTo 0, drawDim.h - additionalWidth
        else
          ctx.moveTo drawDim.w / 2 - baseThikness / 2, drawDim.h
          ctx.lineTo drawDim.w / 2, 0
          ctx.lineTo drawDim.w / 2 + baseThikness / 2, drawDim.h
        ctx.fill()
        ctx.restore()
        style =
          width: realDim.w + "px"
          height: realDim.h + "px"
          left: ""
          right: ""
          top: ""
          bottom: ""

        switch stemPosition
          when Opentip.position.top
            style.top = -realDim.h + "px"
            style.left = -Math.round(realDim.w / 2) + "px"
          when Opentip.position.right
            style.top = -Math.round(realDim.h / 2) + "px"
            style.left = 0
          when Opentip.position.bottom
            style.top = 0
            style.left = -Math.round(realDim.w / 2) + "px"
          when Opentip.position.left
            style.top = -Math.round(realDim.h / 2) + "px"
            style.left = -realDim.w + "px"
          when Opentip.position.topRight
            style.top = -stemSize + "px"
            style.left = -additionalWidth + "px"
          when Opentip.position.bottomRight
            style.top = -additionalWidth + "px"
            style.left = -additionalWidth + "px"
          when Opentip.position.bottomLeft
            style.top = -additionalWidth + "px"
            style.left = -stemSize + "px"
          when Opentip.position.topLeft
            style.top = -stemSize + "px"
            style.left = -stemSize + "px"
          else
            throw "Unknown stem position: " + stemPosition
        canvasElement.setStyle style
        stemContainer = canvasElement.up(".stem-container")
        stemContainer.removeClassName("left").removeClassName("right").removeClassName("center").removeClassName("top").removeClassName("bottom").removeClassName "middle"
        switch stemPosition
          when Opentip.position.top, Opentip.position.topLeft
        , Opentip.position.topRight
            stemContainer.addClassName "top"
          when Opentip.position.bottom, Opentip.position.bottomLeft
        , Opentip.position.bottomRight
            stemContainer.addClassName "bottom"
          else
            stemContainer.addClassName "middle"
        switch stemPosition
          when Opentip.position.left, Opentip.position.topLeft
        , Opentip.position.bottomLeft
            stemContainer.addClassName "left"
          when Opentip.position.right, Opentip.position.topRight
        , Opentip.position.bottomRight
            stemContainer.addClassName "right"
          else
            stemContainer.addClassName "center"

  triggerElementExists: (element) ->
    @triggerElement.parentNode and @triggerElement.visible() and @triggerElement.descendantOf(document.body)

  ensureElementInterval: 1000 # In milliseconds, how often opentip should check for the existance of the element
  ensureElement: -> # Regularely checks if the element is still in the dom.
    @deactivateElementEnsurance()
    @deactivate()  unless @triggerElementExists()
    @ensureElementTimeoutId = setTimeout(@ensureElement.bind(this), @ensureElementInterval)

  deactivateElementEnsurance: ->
    clearTimeout @ensureElementTimeoutId
)