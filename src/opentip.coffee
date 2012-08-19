###
#
# More info at [www.opentip.org](http://www.opentip.org)
# 
# Copyright (c) 2012, Matias Meno  
# Graphics by Tjandra Mayerhold
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
###


# Opentip
# -------
#
# Usage:
# 
#     <div data-ot="This will be viewed in tooltip"></div>
# 
# or externally:
# 
#     new Opentip(element, content, title, options);
# 
# For a full documentation, please visit [www.opentip.org](http://www.opentip.org)
class Opentip

  STICKS_OUT_TOP: 1
  STICKS_OUT_BOTTOM: 2
  STICKS_OUT_LEFT: 1
  STICKS_OUT_RIGHT: 2

  lastTipId: 0

  lastZIndex: 100

  class:
    container: "opentip-container"

    hidden: "hidden"
    hiding: "hiding"
    goingToShow: "going-to-show"
    showing: "showing"
    visible: "visible"

    loading: "loading"
    fixed: "fixed"
    showEffectPrefix: "show-effect-"
    hideEffectPrefix: "hide-effect-"
    stylePrefix: "style-"
  

  # Sets up and configures the tooltip but does **not** build the html elements.
  #
  # `content`, `title` and `options` are optional but have to be in this order.
  constructor: (element, content, title, options) ->
    @id = ++@lastTipId

    @debug "Creating Opentip #{@id}"

    @adapter = Opentip.adapter

    @triggerElement = @adapter.wrap element

    throw new Error "You can't call Opentip on multiple elements." if @triggerElement.length > 1
    throw new Error "Invalid element." if @triggerElement.length < 1

    # AJAX
    @loaded = no
    @loading = no

    @visible = no
    @waitingToShow = no
    @waitingToHide = no

    @lastPosition = left: 0, top: 0
    @dimensions = [ 100, 50 ] # Some initial values

    @content = ""

    # Make sure to not overwrite the users options object
    options = @adapter.clone options

    if typeof content == "object"
      options = content
      content = title = undefined
    else if typeof title == "object"
      options = title
      title = undefined


    # Now build the complete options object from the styles

    options.title = title if title?
    @setContent content if content?

    options.style = Opentip.defaultStyle unless options.style

    # All options are based on the standard style
    styleOptions = @adapter.extend { }, Opentip.styles.standard

    optionSources = [ ]
    # All options are based on the standard style
    optionSources.push Opentip.styles.standard
    optionSources.push Opentip.styles[options.style] unless options.style == "standard"
    optionSources.push options

    options = @adapter.extend { }, optionSources...


    # Sanitize all positions
    options[prop] = @sanitizePosition options[prop] for prop in [
      "tipJoint"
      "targetJoint"
      "stem"
    ]

    # If the url of an Ajax request is not set, get it from the link it's attached to.
    if options.ajax and not options.ajax.url?
      if @adapter.tagName(@triggerElement) == "A"
        options.ajax = { } if typeof options.ajax != "object"
        options.ajax.url = @adapter.attr @triggerElement, "href"
      else 
        options.ajax = off

    # If the event is 'click', no point in following a link
    if options.showOn == "click" && @adapter.tagName(@triggerElement) == "A"
      @adapter.observe @triggerElement, "click", (e) ->
        e.preventDefault()
        e.stopPropagation()
        e.stopped = yes


    # Doesn't make sense to use a target without the opentip being fixed
    options.fixed = yes if options.target

    options.stem = options.tipJoint if options.stem == yes

    if options.target == yes
      options.target = @triggerElement
    else if options.target
      options.target = @adapter.wrap options.target

    @currentStemPosition = options.stem

    unless options.delay?
      options.delay = if options.showOn == "mouseover" then 0.2 else 0

    options.targetJoint = @flipPosition options.tipJoint unless options.targetJoint?

    # Used to show the opentip obviously
    @showTriggersWhenHidden = [ ]

    # Those ensure that opentip doesn't disappear when hovering other related elements
    @showTriggersWhenVisible = [ ]

    # Elements that hide Opentip
    @hideTriggers = [ ]

    # The obvious showTriggerELementWhenHidden is the options.showOn
    if options.showOn and options.showOn != "creation"
      @showTriggersWhenHidden.push
        element: @triggerElement
        event: options.showOn

    @options = options

    # Build the HTML elements when the dom is ready.
    @adapter.domReady => @_init()


  # Initializes the tooltip by creating the container and setting up the event
  # listeners.
  #
  # This does not yet create all elements. They are created when the tooltip
  # actually shows for the first time.
  #
  # This function activates the tooltip as well.
  _init: ->
    @_buildContainer()

    if @options.hideTrigger

      @options.hideTrigger = [ @options.hideTrigger ] unless @options.hideTrigger instanceof Array

      for hideTrigger, i in @options.hideTrigger
        hideOnEvent = null
        hideTriggerElement = null

        hideOn = if @options.hideOn instanceof Array then @options.hideOn[i] else @options.hideOn

        if typeof hideTrigger == "string"
          switch hideTrigger
            when "trigger"
              hideOnEvent = hideOn || "mouseout"
              hideTriggerElement = @triggerElement
            when "tip"
              hideOnEvent = hideOn || "mouseover"
              hideTriggerElement = @container
            when "target"
              hideOnEvent = hideOn || "mouseover"
              hideTriggerElement = this.options.target
            when "closeButton"
              # The close button gets handled later
            else
              throw new Error "Unknown hide trigger: #{hideTrigger}."
        else
          hideOnEvent = hideOn || "mouseover"
          hideTriggerElement = @adapter.wrap hideTrigger

        if hideTriggerElement
          @hideTriggers.push
            element: hideTriggerElement
            event: hideOnEvent

          if hideOnEvent == "mouseout"
            # When the hide trigger is mouseout, we have to attach a mouseover
            # trigger to that element, so the tooltip doesn't disappear when
            # hovering child elements. (Hovering children fires a mouseout
            # mouseover event)
            @showTriggersWhenVisible.push
              element: hideTriggerElement
              event: "mouseover"


    @bound = { }
    @bound[methodToBind] = (do (methodToBind) => return => @[methodToBind].apply this, arguments) for methodToBind in [
      "prepareToShow"
      "prepareToHide"
      "show"
      "hide"
      "reposition"
    ]

    @activate()

    @prepareToShow() if @options.showOn == "creation"

  # This just builds the opentip container, which is the absolute minimum to
  # attach events to it.
  #
  # The actual creation of the elements is in buildElements()
  _buildContainer: ->
    @container = @adapter.create """<div id="opentip-#{@id}" class="#{@class.container} #{@class.hidden} #{@class.stylePrefix}#{@options.className}"></div>"""

    @adapter.addClass @container, @class.loading if @options.ajax
    @adapter.addClass @container, @class.fixed if @options.fixed
    @adapter.addClass @container, "#{@class.showEffectPrefix}#{@options.showEffect}" if @options.showEffect
    @adapter.addClass @container, "#{@class.hideEffectPrefix}#{@options.hideEffect}" if @options.hideEffect

  # Builds all elements inside the container.
  _buildElements: ->

  # Sets the content and updates the HTML element if currently visible
  #
  # This can be a function or a string. The function will be executed, and the
  # result used as new content of the tooltip.
  setContent: (@content) -> @_updateElementContent() if @visible

  # Actually updates the content.
  #
  # If content is a function it is evaluated here.
  _updateElementContent: ->
    contentDiv = @adapter.find @container, ".content"

    if contentDiv?
      if typeof @content == "function"
        @debug "Executing content function."
        @content = @content this
      @adapter.update contentDiv, @content, @options.escapeHtml

    @_storeAndFixDimensions()

  _storeAndFixDimensions: ->
    # TODO
    # this.container.setStyle({width: 'auto', left: '0px', top: '0px'});
    # this.dimensions = this.container.getDimensions();
    # this.container.setStyle({width: this.dimensions.width + 'px', left: this.lastPosition.left + 'px', top: this.lastPosition.top + 'px'});


  # Sets up appropriate observers
  activate: ->
    # The order is important here!
    # "hidden" removes the observers for the `showTriggersWhenVisible` which
    # could be the same as the `showTriggersWhenHidden` which are added by
    # "hiding".
    @_setupObservers "hidden", "hiding"

  # Hides the tooltip and sets up appropriate observers
  deactivate: ->
    @debug "Deactivating tooltip."
    @hide()
    @_setupObservers "hidden"


  _setupObservers: (states...) ->
    for state in states
      switch state
        when "showing"
          # Setup the triggers to hide the tip
          for trigger in @hideTriggers
            @adapter.observe trigger.element, trigger.event, @bound.prepareToHide

          # Remove the triggers to to show the tip
          for trigger in @showTriggersWhenHidden
            @adapter.stopObserving trigger.element, trigger.event, @bound.prepareToShow

          # Start listening to window changes
          @adapter.observe (if document.onresize? then document else window), "resize", @bound.reposition
          @adapter.observe window, "scroll", @bound.reposition
        when "visible"
          # Most of the observers have already been handled by "showing"
          # Add the triggers that make sure opentip doesn't hide prematurely
          for trigger in @showTriggersWhenVisible
            @adapter.observe trigger.element, trigger.event, @bound.prepareToShow
        when "hiding"
          # Setup the triggers to show the tip
          for trigger in @showTriggersWhenHidden
            @adapter.observe trigger.element, trigger.event, @bound.prepareToShow
          
          # Remove the triggers that hide the tip
          for trigger in @hideTriggers
            @adapter.stopObserving trigger.element, trigger.event, @bound.prepareToHide

          # No need to listen for window changes anymore
          @adapter.stopObserving (if document.onresize? then document else window), "resize", @bound.reposition
          @adapter.stopObserving window, "scroll", @bound.reposition
        when "hidden"
          # Most of the observers have already been handled by "hiding"
          # Remove the trigger that would retrigger a `show` when tip is visible.
          for trigger in @showTriggersWhenVisible
            @adapter.stopObserving trigger.element, trigger.event, @bound.prepareToShow
        else
          throw new Error "Unknown state: #{state}"
    null
  prepareToShow: ->
    @_abortHiding()
    return if @visible

    @debug "Showing in #{@options.delay}s."

    Opentip._abortShowingGroup @options.group if @options.group

    @preparingToShow = true

    # Even though it is not yet visible, I already attach the observers, so the
    # tooltip won't show if a hideEvent is triggered.
    @_setupObservers "showing"

    # Making sure the tooltip is at the right position as soon as it shows
    @_followMousePosition()
    @reposition()

    @_showTimeoutId = setTimeout @bound.show, @options.delay || 0

  show: ->
    @_clearTimeouts()
    return if @visible

    # Thanks to Torsten Saam for this enhancement.
    return @deactivate() unless @_triggerElementExists()


    @debug "Showing now."

    Opentip._hideGroup @options.group if @options.group

    @visible = yes
    @preparingToShow = no

    @_buildElement unless @tooltipElement
    @_updateElementContent()


    @_loadAjax() if @options.ajax and not @loaded

    @_searchAndActivateHideButtons()

    @_startEnsureTriggerElement()

    @container.css zIndex: @lastZIndex++

    # The order is important here! Do not reverse.
    @_setupObservers "visible", "showing"

    @reposition()

    @adapter.removeClass @container, @class.hiding
    @adapter.removeClass @container, @class.hidden
    @adapter.addClass @container, @class.goingToShow

    @defer =>
      @setCss3Style @container, "transition-duration": "#{@options.showEffectDuration}s"
      @adapter.removeClass @container, @class.goingToShow
      @adapter.addClass @container, @class.showing

      delay = 0
      delay = @options.showEffectDuration if @options.showEffect and @options.showEffectDuration

      @_visibilityStateTimeoutId = setTimeout =>
        @adapter.removeClass @container, @class.showing
        @adapter.addClass @container, @class.visible
      , delay

      @_activateFirstInput()

  _abortShowing: ->

  prepareToHide: ->

  hide: ->

  _abortHiding: ->
    if @preparingToHide
      @debug "Aborting hiding"
      @_clearTimeouts()
      @preparingToHide = no
      @_setupObservers "showing"

  reposition: ->


  _searchAndActivateHideButtons: ->
    if !@options.hideTrigger or "closeButton" in @options.hideTrigger
      for element in @adapter.findAll @container, ".close"
        @hideTriggers.push
          element: @adapter.wrap element
          event: "click"

      # Creating the observers for the new close buttons
      @_setupObservers "visible" if @visible

  _activateFirstInput: ->
    input = @adapter.unwrap @adapter.find @container, "input, textarea"
    input?.focus?()

  # Calls reposition() everytime the mouse moves
  _followMousePosition: -> @adapter.observe document.body, "mousemove", @bound.reposition unless @options.fixed

  # Removes observer
  _stopFollowingMousePosition: -> @adapter.stopObserving document.body, "mousemove", @bound.reposition unless @options.fixed


  # I thinks those are self explanatory
  _clearShowTimeout: -> clearTimeout @_showTimeoutId
  _clearHideTimeout: -> clearTimeout @_hideTimeoutId
  _clearTimeouts: ->
    clearTimeout @_visibilityStateTimeoutId
    @_clearShowTimeout()
    @_clearHideTimeout()

  # Makes sure the trigger element exists, is visible, and part of this world.
  _triggerElementExists: ->
    el = @adapter.unwrap @triggerElement
    while el.parentNode
      return yes if el.parentNode.tagName == "BODY"
      el = el.parentNode

    # TODO: Add a check if the element is actually visible
    return no

  @_loadAjax: ->
    # TODO
    throw new Error "Not supported yet."


  # Regularely checks if the element is still in the dom.
  _ensureTriggerElement: ->
    unless @_triggerElementExists()
      @deactivate()
      @_stopEnsureTriggerElement()

  # In milliseconds, how often opentip should check for the existance of the element
  _ensureTriggerElementInterval: 1000

  # Sets up an interval to call _ensureTriggerElement regularely
  _startEnsureTriggerElement: ->
    @_ensureTriggerElementTimeoutId = setInterval (=> @_ensureTriggerElement()), @_ensureTriggerElementInterval

  # Stops the interval
  _stopEnsureTriggerElement: ->
    clearInterval @_ensureTriggerElementTimeoutId



# Utils
# -----

vendors = [
  "khtml"
  "ms"
  "o"
  "moz"
  "webkit"
]

# Sets a sepcific css3 value for all vendors
Opentip::setCss3Style = (element, styles) ->
  element = @adapter.unwrap element
  for own prop, value of styles
    for vendor in vendors
      element.style["-#{vendor}-#{prop}"] = value
    element.style[prop] = value

Opentip::defer = (func) -> setTimeout func, 0

Opentip::ucfirst = (string) ->
  return "" unless string?
  string.charAt(0).toUpperCase() + string.slice(1)

# Every position goes through this function
#
# Accepts positions in nearly every form.
#
#   - "top left"
#   - "topLeft"
#   - "top-left"
#   - "RIGHT to TOP"
# 
# All that counts is that the words top, bottom, left or right are present.
Opentip::sanitizePosition = (position) ->
  return position if typeof position == "boolean"
  return null unless position

  position = position.toLowerCase()

  verticalPosition = i for i in [ "top", "bottom" ] when ~position.indexOf i
  horizontalPosition = i for i in [ "left", "right" ] when ~position.indexOf i
  horizontalPosition = @ucfirst horizontalPosition if verticalPosition?

  position = "#{verticalPosition ? ""}#{horizontalPosition ? ""}"
  
  throw "Unknown position: " + position unless Opentip.position[position]?

  position

# Turns topLeft into bottomRight
Opentip::flipPosition = (position) ->
  positionIdx = Opentip.position[position]
  # There are 8 positions, and smart as I am I layed them out in a circle.
  flippedIndex = (positionIdx + 4) % 8
  Opentip.positions[flippedIndex]





# Just forwards to console.debug if Opentip.debug is true and console.debug exists.
Opentip::debug = -> console.debug.apply console, arguments if Opentip.debug and console?.debug?



# Startup
# -------

# TODO write startup script



# Publicly available
# ------------------
Opentip.version = "2.0.0-dev"

Opentip.debug = off

Opentip.tips = [ ]

Opentip._abortShowingGroup = ->
  # TODO

Opentip._hideGroup = ->
  # TODO

# A list of possible adapters. Used for testing
Opentip.adapters = { }

# The current adapter used.
Opentip.adapter = null

Opentip.documentIsLoaded = no


Opentip.positions = [
  "top"
  "topRight"
  "right"
  "bottomRight"
  "bottom"
  "bottomLeft"
  "left"
  "topLeft"
]
Opentip.position = { }
for position, i in Opentip.positions
  Opentip.position[position] = i


# The standard style.
Opentip.styles =
  standard:    
    # This style also contains all default values for other styles.
    #
    # Following abbreviations are used:
    #
    # - `POSITION` : a string that contains at least one of top, bottom, right or left
    # - `COORDINATE` : [ XVALUE, YVALUE ] (integers)
    # - `ELEMENT` : element or element id

    # Will be set if provided in constructor
    title: undefined

    # The class name to be added to the HTML element
    className: "standard"

    # - `false` (no stem)
    # - `true` (stem at tipJoint position)
    # - `POSITION` (for stems in other directions)
    stem: no

    # `float` (in seconds)
    # If null, the default is used: 0.2 for mouseover, 0 for click
    delay: null

    # See delay
    hideDelay: 0.1

    # If target is not null, elements are always fixed.
    fixed: no

    # - eventname (eg: `"click"`, `"mouseover"`, etc..)
    # - `"creation"` (the tooltip will show when being created)
    # - `null` if you want to handle it yourself (Opentip will not register for any events)
    showOn: "mouseover"

    # - `"trigger"`
    # - `"tip"`
    # - `"target"`
    # - `"closeButton"`
    # - `ELEMENT`
    # - Or an array containing any of the previous
    hideTrigger: "trigger"

    # - eventname (eg: `"click"`)
    # - array of event strings if multiple hideTriggers
    # - `null` (let Opentip decide)
    hideOn: null

    # `COORDINATE`
    offset: [ 0, 0 ]

    # Whether the targetJoint/tipJoint should be changed if the tooltip is not in the viewport anymore.
    containInViewport: true

    # If set to true, offsets are calculated automatically to position the tooltip. (pixels are added if there are stems for example)
    autoOffset: true

    showEffect: "appear"
    hideEffect: "fade"
    showEffectDuration: 0.3
    hideEffectDuration: 0.2

    # integer
    stemSize: 8

    # `POSITION`
    tipJoint: "top left"

    # - `null` (no target, opentip uses mouse as target)
    # - `true` (target is the triggerElement)
    # - `ELEMENT` (for another element)
    target: null 

    # - `POSITION` (Ignored if target == `null`)
    # - `null` (targetJoint is the opposite of tipJoint)
    targetJoint: null 

    # AJAX options object consisting of:
    #
    #   - **url**
    #   - **method**
    #
    # If opentip is attached to an `<a />` element, and no url is provided, it will use
    # The elements `href` attribute.
    ajax: off

    # You can group opentips together. So when a tooltip shows, it looks if there are others in the same group, and hides them.
    group: null

    escapeHtml: false

    # Will be set automatically in constructor
    style: null

  slick:
    className: "slick"
    stem: true
  rounded:
    className: "rounded"
    stem: true
  glass:
    className: "glass"


# Change this to the style name you want all your tooltips to have as default.
Opentip.defaultStyle = "standard"





