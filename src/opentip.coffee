###
#
# Opentip v2.4.6
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


  class:
    container: "opentip-container"
    opentip: "opentip"
    header: "ot-header"
    content: "ot-content"
    loadingIndicator: "ot-loading-indicator"
    close: "ot-close"

    goingToHide: "ot-going-to-hide"
    hidden: "ot-hidden"
    hiding: "ot-hiding"
    goingToShow: "ot-going-to-show"
    showing: "ot-showing"
    visible: "ot-visible"

    loading: "ot-loading"
    ajaxError: "ot-ajax-error"
    fixed: "ot-fixed"
    showEffectPrefix: "ot-show-effect-"
    hideEffectPrefix: "ot-hide-effect-"
    stylePrefix: "style-"
  

  # Sets up and configures the tooltip but does **not** build the html elements.
  #
  # `content`, `title` and `options` are optional but have to be in this order.
  constructor: (element, content, title, options) ->
    @id = ++Opentip.lastId

    @debug "Creating Opentip."

    Opentip.tips.push this

    @adapter = Opentip.adapter

    # Add the ID to the element
    elementsOpentips = @adapter.data(element, "opentips") || [ ]
    elementsOpentips.push this
    @adapter.data element, "opentips", elementsOpentips

    @triggerElement = @adapter.wrap element

    throw new Error "You can't call Opentip on multiple elements." if @triggerElement.length > 1
    throw new Error "Invalid element." if @triggerElement.length < 1

    # AJAX
    @loaded = no
    @loading = no

    @visible = no
    @waitingToShow = no
    @waitingToHide = no

    # Some initial values
    @currentPosition = left: 0, top: 0
    @dimensions = width: 100, height: 50

    @content = ""

    @redraw = on

    @currentObservers =
      showing: no
      visible: no
      hiding: no
      hidden: no

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

    unless options.extends?
      if options.style?
        options.extends = options.style
      else
        options.extends = Opentip.defaultStyle

    optionSources = [ options ]

    # Now add go through the theme hierarchy and apply the options
    _tmpStyle = options
    while _tmpStyle.extends
      styleName = _tmpStyle.extends
      _tmpStyle = Opentip.styles[styleName]
      throw new Error "Invalid style: #{styleName}" unless _tmpStyle?
      optionSources.unshift _tmpStyle

      # Now making sure that all styles result in the standard style, even when not
      # specified
      _tmpStyle.extends = "standard" unless _tmpStyle.extends? or styleName == "standard"

    options = @adapter.extend { }, optionSources...

    # Deep copying the hideTriggers array
    options.hideTriggers = (hideTrigger for hideTrigger in options.hideTriggers)

    options.hideTriggers.push options.hideTrigger if options.hideTrigger and options.hideTriggers.length == 0

    # Sanitize all positions
    options[prop] = new Opentip.Joint(options[prop]) for prop in [
      "tipJoint"
      "targetJoint"
      "stem"
    ] when options[prop] and typeof options[prop] == "string"

    # If the url of an Ajax request is not set, get it from the link it's attached to.
    if options.ajax and (options.ajax == on or not options.ajax)
      if @adapter.tagName(@triggerElement) == "A"
        options.ajax = @adapter.attr @triggerElement, "href"
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

    options.stem = new Opentip.Joint(options.tipJoint) if options.stem == yes

    if options.target == yes
      options.target = @triggerElement
    else if options.target
      options.target = @adapter.wrap options.target

    @currentStem = options.stem

    unless options.delay?
      options.delay = if options.showOn == "mouseover" then 0.2 else 0

    unless options.targetJoint?
      options.targetJoint = new Opentip.Joint(options.tipJoint).flip()

    # Used to show the opentip obviously
    @showTriggers = [ ]

    # Those ensure that opentip doesn't disappear when hovering other related elements
    @showTriggersWhenVisible = [ ]

    # Elements that hide Opentip
    @hideTriggers = [ ]

    # The obvious showTriggerELementWhenHidden is the options.showOn
    if options.showOn and options.showOn != "creation"
      @showTriggers.push
        element: @triggerElement
        event: options.showOn


    # Backwards compatibility
    if options.ajaxCache?
      options.cache = options.ajaxCache
      delete options.ajaxCache

    @options = options


    @bound = { }
    @bound[methodToBind] = (do (methodToBind) => return => @[methodToBind](arguments...)) for methodToBind in [
      "prepareToShow"
      "prepareToHide"
      "show"
      "hide"
      "reposition"
    ]

    # Build the HTML elements when the dom is ready.
    @adapter.domReady =>
      @activate()
      @prepareToShow() if @options.showOn == "creation"


  # Initializes the tooltip by creating the container and setting up the event
  # listeners.
  #
  # This does not yet create all elements. They are created when the tooltip
  # actually shows for the first time.
  _setup: ->
    @debug "Setting up the tooltip."
    @_buildContainer()

    @hideTriggers = [ ]

    for hideTrigger, i in @options.hideTriggers
      hideTriggerElement = null

      hideOn = if @options.hideOn instanceof Array then @options.hideOn[i] else @options.hideOn

      if typeof hideTrigger == "string"
        switch hideTrigger
          when "trigger"
            hideOn = hideOn || "mouseout"
            hideTriggerElement = @triggerElement
          when "tip"
            hideOn = hideOn || "mouseover"
            hideTriggerElement = @container
          when "target"
            hideOn = hideOn || "mouseover"
            hideTriggerElement = this.options.target
          when "closeButton"
            # The close button gets handled later
          else
            throw new Error "Unknown hide trigger: #{hideTrigger}."
      else
        hideOn = hideOn || "mouseover"
        hideTriggerElement = @adapter.wrap hideTrigger

      if hideTriggerElement
        @hideTriggers.push
          element: hideTriggerElement
          event: hideOn
          original: hideTrigger

    # Now setup the events that make sure opentips don't appear when mouseover
    # another hideTrigger
    # 
    # This also solves the problem of the tooltip disappearing when hovering child
    # elements (Hovering children fires a mouseout mouseover event)
    for hideTrigger in @hideTriggers
      @showTriggersWhenVisible.push
        element: hideTrigger.element
        event: "mouseover"


  # This just builds the opentip container, which is the absolute minimum to
  # attach events to it.
  #
  # The actual creation of the elements is in buildElements()
  _buildContainer: ->
    @container = @adapter.create """<div id="opentip-#{@id}" class="#{@class.container} #{@class.hidden} #{@class.stylePrefix}#{@options.className}"></div>"""

    @adapter.css @container, position: "absolute"

    @adapter.addClass @container, @class.loading if @options.ajax
    @adapter.addClass @container, @class.fixed if @options.fixed
    @adapter.addClass @container, "#{@class.showEffectPrefix}#{@options.showEffect}" if @options.showEffect
    @adapter.addClass @container, "#{@class.hideEffectPrefix}#{@options.hideEffect}" if @options.hideEffect

  # Builds all elements inside the container and put the container in body.
  _buildElements: ->
    # The actual content will be set by `_updateElementContent()`
    @tooltipElement = @adapter.create """<div class="#{@class.opentip}"><div class="#{@class.header}"></div><div class="#{@class.content}"></div></div>"""

    @backgroundCanvas = @adapter.wrap document.createElement "canvas"
    @adapter.css @backgroundCanvas, position: "absolute"

    G_vmlCanvasManager?.initElement @adapter.unwrap @backgroundCanvas

    headerElement = @adapter.find @tooltipElement, ".#{@class.header}"

    if @options.title
      # Create the title element and append it to the header
      titleElement = @adapter.create """<h1></h1>"""
      @adapter.update titleElement, @options.title, @options.escapeTitle
      @adapter.append headerElement, titleElement

    if @options.ajax and !@loaded
      @adapter.append @tooltipElement, @adapter.create """<div class="#{@class.loadingIndicator}"><span>↻</span></div>"""

    if "closeButton" in @options.hideTriggers
      @closeButtonElement = @adapter.create """<a href="javascript:undefined;" class="#{@class.close}"><span>Close</span></a>"""
      @adapter.append headerElement, @closeButtonElement

    # Now put the tooltip and the canvas in the container and the container in the body
    @adapter.append @container, @backgroundCanvas
    @adapter.append @container, @tooltipElement
    @adapter.append document.body, @container

    # Makes sure that the content is redrawn.
    @_newContent = yes
    @redraw = on

  # Sets the content and updates the HTML element if currently visible
  #
  # This can be a function or a string. The function will be executed, and the
  # result used as new content of the tooltip.
  setContent: (@content) ->
    @_newContent = yes

    if typeof @content == "function"
      @_contentFunction = @content
      @content = ""
    else
      @_contentFunction = null

    @_updateElementContent() if @visible

  # Actually updates the content.
  #
  # If content is a function it is evaluated here.
  _updateElementContent: ->
    if @_newContent or (!@options.cache and @_contentFunction)
      contentDiv = @adapter.find @container, ".#{@class.content}"

      if contentDiv?
        if @_contentFunction
          @debug "Executing content function."
          @content = @_contentFunction this
        @adapter.update contentDiv, @content, @options.escapeContent

      @_newContent = no

    @_storeAndLockDimensions()
    @reposition()

  # Sets width auto to the element so it uses the appropriate width, gets the
  # dimensions and sets them so the tolltip won't change in size (which can be
  # annoying when the tooltip gets too close to the browser edge)
  _storeAndLockDimensions: ->
    return unless @container
    prevDimension = @dimensions

    @adapter.css @container,
      width: "auto"
      left: "0px" # So it doesn't force wrapping
      top: "0px"
    @dimensions = @adapter.dimensions @container
    # Firefox <=3.6 has a strange wrapping proplem when taking the exact width
    @dimensions.width += 1

    @adapter.css @container,
      width: "#{@dimensions.width}px"
      top: "#{@currentPosition.top}px"
      left: "#{@currentPosition.left}px"

    unless @_dimensionsEqual @dimensions, prevDimension
      @redraw = on 
      @_draw()

  # Sets up appropriate observers
  activate: ->
    @_setupObservers "hidden", "hiding"

  # Hides the tooltip and sets up appropriate observers
  deactivate: ->
    @debug "Deactivating tooltip."
    @hide()
    @_setupObservers "-showing", "-visible", "-hidden", "-hiding"


  # If a state starts with a minus all observers are removed instead of set.
  _setupObservers: (states...) ->
    for state in states

      removeObserver = no
      if state.charAt(0) == "-"
        removeObserver = yes
        state = state.substr 1 # Remove leading -

      # Do nothing if the state is already achieved
      continue if @currentObservers[state] is not removeObserver
      @currentObservers[state] = not removeObserver

      observeOrStop = (args...) =>
        if removeObserver then @adapter.stopObserving args...
        else @adapter.observe args...

      switch state
        when "showing"
          # Setup the triggers to hide the tip
          for trigger in @hideTriggers
            observeOrStop trigger.element, trigger.event, @bound.prepareToHide

          # Start listening to window changes
          observeOrStop (if document.onresize? then document else window), "resize", @bound.reposition
          observeOrStop window, "scroll", @bound.reposition

        when "visible"
          # Most of the observers have already been handled by "showing"
          # Add the triggers that make sure opentip doesn't hide prematurely
          for trigger in @showTriggersWhenVisible
            observeOrStop trigger.element, trigger.event, @bound.prepareToShow

        when "hiding"
          # Setup the triggers to show the tip
          for trigger in @showTriggers
            observeOrStop trigger.element, trigger.event, @bound.prepareToShow
          
        when "hidden"
          # Nothing to do since all observers are setup in "hiding"

        else
          throw new Error "Unknown state: #{state}"

    null # No unnecessary array collection

  prepareToShow: ->
    @_abortHiding()
    @_abortShowing()
    return if @visible

    @debug "Showing in #{@options.delay}s."

    @_setup() unless @container?

    Opentip._abortShowingGroup @options.group, this if @options.group

    @preparingToShow = true

    # Even though it is not yet visible, I already attach the observers, so the
    # tooltip won't show if a hideEvent is triggered.
    @_setupObservers "-hidden", "-hiding", "showing"

    # Making sure the tooltip is at the right position as soon as it shows
    @_followMousePosition()
    @initialMousePosition = mousePosition if @options.fixed and !@options.target # Used in reposition
    @reposition()

    @_showTimeoutId = @setTimeout @bound.show, @options.delay || 0

  show: ->
    @_abortHiding()

    return if @visible

    @_clearTimeouts()

    return @deactivate() unless @_triggerElementExists()

    @debug "Showing now."
    @_setup() unless @container?

    Opentip._hideGroup @options.group, this if @options.group

    @visible = yes
    @preparingToShow = no

    @_buildElements() unless @tooltipElement?
    @_updateElementContent()

    @_loadAjax() if @options.ajax and (not @loaded or not @options.cache)

    @_searchAndActivateCloseButtons()

    @_startEnsureTriggerElement()

    @adapter.css @container, zIndex: Opentip.lastZIndex++

    # The order is important here! Do not reverse.
    # Removing the showing and visible triggers as well in case they have been
    # removed by -hidden or -hiding
    @_setupObservers "-hidden", "-hiding", "-showing", "-visible", "showing", "visible"

    @initialMousePosition = mousePosition if @options.fixed and !@options.target # Used in reposition
    @reposition()

    @adapter.removeClass @container, @class.hiding
    @adapter.removeClass @container, @class.hidden
    @adapter.addClass @container, @class.goingToShow
    @setCss3Style @container, transitionDuration: "0s"

    @defer =>
      # Since this function is deferred, a hide() call could have already been made
      return if !@visible or @preparingToHide
      @adapter.removeClass @container, @class.goingToShow
      @adapter.addClass @container, @class.showing

      delay = 0
      delay = @options.showEffectDuration if @options.showEffect and @options.showEffectDuration
      @setCss3Style @container, transitionDuration: "#{delay}s"

      @_visibilityStateTimeoutId = @setTimeout =>
        @adapter.removeClass @container, @class.showing
        @adapter.addClass @container, @class.visible
      , delay

      @_activateFirstInput()

    # Just making sure the canvas has been drawn initially.
    # It could happen that the canvas isn't drawn yet when reposition is called
    # once before the canvas element has been created. If the position
    # doesn't change after it will never call @_draw() again.
    @_draw()

  _abortShowing: ->
    if @preparingToShow
      @debug "Aborting showing."
      @_clearTimeouts()
      @_stopFollowingMousePosition()
      @preparingToShow = false
      @_setupObservers "-showing", "-visible", "hiding", "hidden"

  prepareToHide: ->
    @_abortShowing()
    @_abortHiding()

    return unless @visible

    @debug "Hiding in #{@options.hideDelay}s"

    @preparingToHide = yes

    # We start observing even though it is not yet hidden, so the tooltip does
    # not disappear when a showEvent is triggered.
    @_setupObservers "-showing", "visible", "-hidden", "hiding"

    @_hideTimeoutId = @setTimeout @bound.hide, @options.hideDelay

  hide: ->
    @_abortShowing()

    return unless @visible

    @_clearTimeouts()

    @debug "Hiding!"

    @visible = no

    @preparingToHide = no

    @_stopEnsureTriggerElement()

    # Removing hiding and hidden as well in case some events have been removed
    # by -showing or -visible
    @_setupObservers "-showing", "-visible", "-hiding", "-hidden", "hiding", "hidden"

    @_stopFollowingMousePosition() unless @options.fixed

    return unless @container
 
    @adapter.removeClass @container, @class.visible
    @adapter.removeClass @container, @class.showing
    @adapter.addClass @container, @class.goingToHide
    @setCss3Style @container, transitionDuration: "0s"

    @defer =>
      @adapter.removeClass @container, @class.goingToHide
      @adapter.addClass @container, @class.hiding

      hideDelay = 0
      hideDelay = @options.hideEffectDuration if @options.hideEffect and @options.hideEffectDuration
      @setCss3Style @container, { transitionDuration: "#{hideDelay}s" }

      @_visibilityStateTimeoutId = @setTimeout =>
        @adapter.removeClass @container, @class.hiding
        @adapter.addClass @container, @class.hidden
        @setCss3Style @container, { transitionDuration: "0s" }

        if @options.removeElementsOnHide
          @debug "Removing HTML elements."
          @adapter.remove @container
          delete @container
          delete @tooltipElement
      , hideDelay

  _abortHiding: ->
    if @preparingToHide
      @debug "Aborting hiding."
      @_clearTimeouts()
      @preparingToHide = no
      @_setupObservers "-hiding", "showing", "visible"

  reposition: ->
    position = @getPosition()
    return unless position?

    stem = @options.stem

    {position, stem} = @_ensureViewportContainment position if @options.containInViewport

    # If the position didn't change, no need to do anything    
    return if @_positionsEqual position, @currentPosition

    # The only time the canvas has to bee redrawn is when the stem changes.
    @redraw = on unless !@options.stem or stem.eql @currentStem

    @currentPosition = position
    @currentStem = stem

    # _draw() itself tests if it has to be redrawn.
    @_draw()

    @adapter.css @container, { left: "#{position.left}px", top: "#{position.top}px" }

    # Following is a redraw fix, because I noticed some drawing errors in
    # some browsers when tooltips where overlapping.
    @defer =>
      rawContainer = @adapter.unwrap @container
      # I chose visibility instead of display so that I don't interfere with
      # appear/disappear effects.
      rawContainer.style.visibility = "hidden"
      redrawFix = rawContainer.offsetHeight
      rawContainer.style.visibility = "visible"


  getPosition: (tipJoint, targetJoint, stem) ->
    return unless @container

    tipJoint ?= @options.tipJoint
    targetJoint ?= @options.targetJoint

    position = { }

    if @options.target
      # Position is fixed
      targetPosition = @adapter.offset @options.target
      targetDimensions = @adapter.dimensions @options.target

      position = targetPosition

      if targetJoint.right
        # For wrapping inline elements, left + width does not give the right
        # border, because left is where the element started, not its most left
        # position.
        unwrappedTarget = @adapter.unwrap @options.target
        if unwrappedTarget.getBoundingClientRect?
          # TODO: make sure this actually works.
          position.left = unwrappedTarget.getBoundingClientRect().right + (window.pageXOffset ? document.body.scrollLeft)
        else
          # Well... browser doesn't support it
          position.left += targetDimensions.width
      else if targetJoint.center
        # Center
        position.left += Math.round targetDimensions.width / 2

      if targetJoint.bottom
        position.top += targetDimensions.height
      else if targetJoint.middle
        # Middle
        position.top += Math.round targetDimensions.height / 2

      if @options.borderWidth
        if @options.tipJoint.left
          position.left += @options.borderWidth
        if @options.tipJoint.right
          position.left -= @options.borderWidth
        if @options.tipJoint.top
          position.top += @options.borderWidth
        else if @options.tipJoint.bottom
          position.top -= @options.borderWidth
        

    else
      if @initialMousePosition
        # When the tooltip is fixed and has no target the position is stored at the beginning.
        position = top: @initialMousePosition.y, left: @initialMousePosition.x
      else
        # Follow mouse
        position = top: mousePosition.y, left: mousePosition.x

    if @options.autoOffset
      stemLength = if @options.stem then @options.stemLength else 0

      # If there is as stem offsets dont need to be that big if fixed.
      offsetDistance = if stemLength and @options.fixed then 2 else 10

      # Corners can be closer but when middle or center they are too close
      additionalHorizontal = if tipJoint.middle and not @options.fixed then 15 else 0
      additionalVertical = if tipJoint.center and not @options.fixed then 15 else 0

      if tipJoint.right then position.left -= offsetDistance + additionalHorizontal
      else if tipJoint.left then position.left += offsetDistance + additionalHorizontal

      if tipJoint.bottom then position.top -= offsetDistance + additionalVertical
      else if tipJoint.top then position.top += offsetDistance + additionalVertical

      if stemLength
        stem ?= @options.stem
        if stem.right then position.left -= stemLength
        else if stem.left then position.left += stemLength

        if stem.bottom then position.top -= stemLength
        else if stem.top then position.top += stemLength

    position.left += @options.offset[0]
    position.top += @options.offset[1]

    if tipJoint.right then position.left -= @dimensions.width
    else if tipJoint.center then position.left -= Math.round @dimensions.width / 2

    if tipJoint.bottom then position.top -= @dimensions.height
    else if tipJoint.middle then position.top -= Math.round @dimensions.height / 2

    position

  _ensureViewportContainment: (position) ->

    stem = @options.stem

    originals = {
      position: position
      stem: stem
    }

    # Sometimes the element is theoretically visible, but an effect is not yet showing it.
    # So the calculation of the offsets is incorrect sometimes, which results in faulty repositioning.
    return originals unless @visible and position
    
    sticksOut = @_sticksOut position

    return originals unless sticksOut[0] or sticksOut[1]

    tipJoint = new Opentip.Joint @options.tipJoint
    targetJoint = new Opentip.Joint @options.targetJoint if @options.targetJoint

    scrollOffset = @adapter.scrollOffset()
    viewportDimensions = @adapter.viewportDimensions()

    # The opentip's position inside the viewport
    viewportPosition = [
      position.left - scrollOffset[0]
      position.top - scrollOffset[1]
    ]

    needsRepositioning = no



    if viewportDimensions.width >= @dimensions.width
      # Well if the viewport is smaller than the tooltip there's not much to do
      if sticksOut[0]
        needsRepositioning = yes

        switch sticksOut[0]
          when @STICKS_OUT_LEFT
            tipJoint.setHorizontal "left"
            targetJoint.setHorizontal "right" if @options.targetJoint
          when @STICKS_OUT_RIGHT
            tipJoint.setHorizontal "right"
            targetJoint.setHorizontal "left" if @options.targetJoint

    if viewportDimensions.height >= @dimensions.height
      # Well if the viewport is smaller than the tooltip there's not much to do
      if sticksOut[1]
        needsRepositioning = yes

        switch sticksOut[1]
          when @STICKS_OUT_TOP
            tipJoint.setVertical "top"
            targetJoint.setVertical "bottom" if @options.targetJoint
          when @STICKS_OUT_BOTTOM
            tipJoint.setVertical "bottom"
            targetJoint.setVertical "top" if @options.targetJoint

    return originals unless needsRepositioning

    # Needs to reposition

    # TODO: actually handle the stem here
    stem = tipJoint if @options.stem
    position = @getPosition tipJoint, targetJoint, stem

    newSticksOut = @_sticksOut position

    revertedX = no
    revertedY = no

    if newSticksOut[0] and (newSticksOut[0] isnt sticksOut[0])
      # The tooltip changed sides, but now is sticking out the other side of
      # the window.
      revertedX = yes
      tipJoint.setHorizontal @options.tipJoint.horizontal
      targetJoint.setHorizontal @options.targetJoint.horizontal if @options.targetJoint
    if newSticksOut[1] and (newSticksOut[1] isnt sticksOut[1])
      revertedY = yes
      tipJoint.setVertical @options.tipJoint.vertical
      targetJoint.setVertical @options.targetJoint.vertical if @options.targetJoint


    return originals if revertedX and revertedY
      
    if revertedX or revertedY
      # One of the positions have been reverted. So get the position again.
      stem = tipJoint if @options.stem
      position = @getPosition tipJoint, targetJoint, stem

    {
      position: position
      stem: stem
    }



  _sticksOut: (position) ->
    scrollOffset = @adapter.scrollOffset()
      
    viewportDimensions = @adapter.viewportDimensions()
   
    positionOffset = [
      position.left - scrollOffset[0]
      position.top - scrollOffset[1]
    ]

    sticksOut = [ no, no ]

    if positionOffset[0] < 0
      sticksOut[0] = @STICKS_OUT_LEFT 
    else if positionOffset[0] + @dimensions.width > viewportDimensions.width
      sticksOut[0] = @STICKS_OUT_RIGHT

    if positionOffset[1] < 0
      sticksOut[1] = @STICKS_OUT_TOP 
    else if positionOffset[1] + @dimensions.height > viewportDimensions.height
      sticksOut[1] = @STICKS_OUT_BOTTOM 

    sticksOut

  # This is by far the most complex and difficult function to understand. It
  # actually draws the canvas.
  # 
  # I tried to comment everything as good as possible.
  _draw: ->
    # This function could be called before _buildElements()
    return unless @backgroundCanvas and @redraw

    @debug "Drawing background."

    @redraw = off

    # Take care of the classes
    if @currentStem
      @adapter.removeClass @container, "stem-#{position}" for position in [ "top", "right", "bottom", "left" ]
      @adapter.addClass @container, "stem-#{@currentStem.horizontal}"
      @adapter.addClass @container, "stem-#{@currentStem.vertical}"



    # Prepare for the close button
    closeButtonInner = [ 0, 0 ]
    closeButtonOuter = [ 0, 0 ]
    if "closeButton" in @options.hideTriggers
      closeButton = new Opentip.Joint(if @currentStem?.toString() == "top right" then "top left" else "top right")
      closeButtonInner = [
        @options.closeButtonRadius + @options.closeButtonOffset[0]
        @options.closeButtonRadius + @options.closeButtonOffset[1]
      ]
      closeButtonOuter = [
        @options.closeButtonRadius - @options.closeButtonOffset[0]
        @options.closeButtonRadius - @options.closeButtonOffset[1]
      ]

    # Now for the canvas dimensions and position
    canvasDimensions = @adapter.clone @dimensions
    canvasPosition = [ 0, 0 ]

    # Account for border
    if @options.borderWidth
      canvasDimensions.width += @options.borderWidth * 2
      canvasDimensions.height += @options.borderWidth * 2
      canvasPosition[0] -= @options.borderWidth
      canvasPosition[1] -= @options.borderWidth

    # Account for the shadow
    if @options.shadow
      canvasDimensions.width += @options.shadowBlur * 2
      # If the shadow offset is bigger than the actual shadow blur, the whole canvas gets bigger
      canvasDimensions.width += Math.max 0, @options.shadowOffset[0] - @options.shadowBlur * 2
      
      canvasDimensions.height += @options.shadowBlur * 2
      canvasDimensions.height += Math.max 0, @options.shadowOffset[1] - @options.shadowBlur * 2

      canvasPosition[0] -= Math.max 0, @options.shadowBlur - @options.shadowOffset[0]
      canvasPosition[1] -= Math.max 0, @options.shadowBlur - @options.shadowOffset[1]

    # * * *

    # Bulges could be caused by stems or close buttons
    bulge = left: 0, right: 0, top: 0, bottom: 0

    # Account for the stem
    if @currentStem
      if @currentStem.left then bulge.left = @options.stemLength
      else if @currentStem.right then bulge.right = @options.stemLength

      if @currentStem.top then bulge.top = @options.stemLength
      else if @currentStem.bottom then bulge.bottom = @options.stemLength

    # Account for the close button
    if closeButton
      if closeButton.left then bulge.left = Math.max bulge.left, closeButtonOuter[0]
      else if closeButton.right then bulge.right = Math.max bulge.right, closeButtonOuter[0]

      if closeButton.top then bulge.top = Math.max bulge.top, closeButtonOuter[1]
      else if closeButton.bottom then bulge.bottom = Math.max bulge.bottom, closeButtonOuter[1]


    canvasDimensions.width += bulge.left + bulge.right
    canvasDimensions.height += bulge.top + bulge.bottom
    canvasPosition[0] -= bulge.left
    canvasPosition[1] -= bulge.top


    if @currentStem and @options.borderWidth
      {stemLength, stemBase} = @_getPathStemMeasures @options.stemBase, @options.stemLength, @options.borderWidth


    # Need to draw on the DOM canvas element itself
    backgroundCanvas = @adapter.unwrap @backgroundCanvas

    backgroundCanvas.width = canvasDimensions.width
    backgroundCanvas.height = canvasDimensions.height

    @adapter.css @backgroundCanvas,
      width: "#{backgroundCanvas.width}px"
      height: "#{backgroundCanvas.height}px"
      left: "#{canvasPosition[0]}px"
      top: "#{canvasPosition[1]}px"


    ctx = backgroundCanvas.getContext "2d"

    ctx.setTransform 1, 0, 0, 1, 0, 0

    ctx.clearRect 0, 0, backgroundCanvas.width, backgroundCanvas.height
    ctx.beginPath()

    ctx.fillStyle = @_getColor ctx, @dimensions, @options.background, @options.backgroundGradientHorizontal
    ctx.lineJoin = "miter"
    ctx.miterLimit = 500

    # Since borders are always in the middle and I want them outside I need to
    # draw the actual path half the border width outset.
    #
    # (hb = half border)
    hb = @options.borderWidth / 2

    if @options.borderWidth
      ctx.strokeStyle = @options.borderColor
      ctx.lineWidth = @options.borderWidth
    else
      stemLength = @options.stemLength
      stemBase = @options.stemBase


    stemBase ?= 0


    # Draws a line with stem if necessary
    drawLine = (length, stem, first) =>
      if first
        # This ensures that the outline is properly closed
        ctx.moveTo Math.max(stemBase, @options.borderRadius, closeButtonInner[0]) + 1 - hb, -hb
      if stem
        ctx.lineTo length / 2 - stemBase / 2, -hb
        ctx.lineTo length / 2, - stemLength - hb
        ctx.lineTo length / 2 + stemBase / 2, -hb

    # Draws a corner with stem if necessary
    drawCorner = (stem, closeButton, i) =>
      if stem
        ctx.lineTo -stemBase + hb, 0 - hb
        ctx.lineTo stemLength + hb, -stemLength - hb
        ctx.lineTo hb, stemBase - hb
      else if closeButton
        offset = @options.closeButtonOffset
        innerWidth = closeButtonInner[0]

        if i % 2 != 0
          # Since the canvas gets rotated for every corner, but the close button
          # is always defined as [ horizontal, vertical ] offsets, I have to switch
          # the offsets in case the canvas is rotated by 90degs
          offset = [ offset[1], offset[0] ]
          innerWidth = closeButtonInner[1]

        # Basic math
        #
        # I added a graphical explanation since it's sometimes hard to understand 
        # geometrical calculations without visualization:
        # https://raw.github.com/enyo/opentip/develop/files/close-button-angle.png
        angle1 = Math.acos(offset[1] / @options.closeButtonRadius)
        angle2 = Math.acos(offset[0] / @options.closeButtonRadius)

        ctx.lineTo -innerWidth + hb, -hb

        # Firefox 3.6 requires the last boolean parameter (anticlockwise)
        ctx.arc hb-offset[0], -hb+offset[1], @options.closeButtonRadius, -(Math.PI / 2 + angle1), angle2, no
      else
        ctx.lineTo -@options.borderRadius + hb, -hb
        ctx.quadraticCurveTo hb, -hb, hb, @options.borderRadius - hb


    # Start drawing without caring about the shadows or stems
    # The canvas position is exactly the amount that has been moved to account
    # for shadows and stems
    ctx.translate -canvasPosition[0], -canvasPosition[1]

    ctx.save()

    do => # Wrapping variables

      # This part is a bit funky...
      # All in all I just iterate over all four corners, translate the canvas
      # to it and rotate it so the next line goes to the right.
      # This way I can call drawLine and drawCorner withouth them knowing which
      # line their actually currently drawing.
      for i in [0...Opentip.positions.length/2]
        positionIdx = i * 2

        positionX = if i == 0 or i == 3 then 0 else @dimensions.width
        positionY = if i < 2 then 0 else @dimensions.height
        rotation = (Math.PI / 2) * i
        lineLength = if i % 2 == 0 then @dimensions.width else @dimensions.height
        lineStem = new Opentip.Joint Opentip.positions[positionIdx]
        cornerStem = new Opentip.Joint Opentip.positions[positionIdx + 1]

        ctx.save()
        ctx.translate positionX, positionY
        ctx.rotate rotation
        drawLine lineLength, lineStem.eql(@currentStem), i == 0
        ctx.translate lineLength, 0
        drawCorner cornerStem.eql(@currentStem), cornerStem.eql(closeButton), i
        ctx.restore()

    ctx.closePath()
    ctx.save()

    if @options.shadow
      ctx.shadowColor = @options.shadowColor
      ctx.shadowBlur = @options.shadowBlur
      ctx.shadowOffsetX = @options.shadowOffset[0]
      ctx.shadowOffsetY = @options.shadowOffset[1]

    ctx.fill()
    ctx.restore() # Without shadow
    ctx.stroke() if @options.borderWidth

    ctx.restore() # Without shadow

    if closeButton
      do =>
        # Draw the cross
        crossWidth = crossHeight = @options.closeButtonRadius * 2

        if closeButton.toString() == "top right"
          linkCenter = [
            @dimensions.width - @options.closeButtonOffset[0]
            @options.closeButtonOffset[1]
          ]
          crossCenter = [
            linkCenter[0] + hb
            linkCenter[1] - hb
          ]
        else
          linkCenter = [
            @options.closeButtonOffset[0]
            @options.closeButtonOffset[1]
          ]
          crossCenter = [
            linkCenter[0] - hb
            linkCenter[1] - hb
          ]

        ctx.translate crossCenter[0], crossCenter[1]

        hcs = @options.closeButtonCrossSize / 2

        ctx.save()

        ctx.beginPath()

        ctx.strokeStyle = @options.closeButtonCrossColor
        ctx.lineWidth = @options.closeButtonCrossLineWidth
        ctx.lineCap = "round"

        ctx.moveTo -hcs, -hcs
        ctx.lineTo hcs, hcs
        ctx.stroke()

        ctx.beginPath()
        ctx.moveTo hcs, -hcs
        ctx.lineTo -hcs, hcs
        ctx.stroke()

        ctx.restore()

        # Position the link
        
        @adapter.css @closeButtonElement,
          left: "#{linkCenter[0] - hcs - @options.closeButtonLinkOverscan}px"
          top: "#{linkCenter[1] - hcs - @options.closeButtonLinkOverscan}px"
          width: "#{@options.closeButtonCrossSize + @options.closeButtonLinkOverscan * 2}px"
          height: "#{@options.closeButtonCrossSize + @options.closeButtonLinkOverscan * 2}px"


  # I have to account for the border width when implementing the stems. The
  # tip height & width obviously should be added to the outer border, but
  # the path is drawn in the middle of the border.
  # If I just draw the stem size specified on the path, the stem will be
  # bigger than requested.
  #
  # So I have to calculate the stemBase and stemLength of the **path**
  # stem.
  _getPathStemMeasures: (outerStemBase, outerStemLength, borderWidth) ->
    # Now for some math!
    #
    #      /
    #     /|\
    #    / | angle
    #   /  |  \
    #  /   |   \
    # /____|____\

    hb = borderWidth / 2

    # This is the angle of the tip
    halfAngle = Math.atan (outerStemBase / 2) / outerStemLength
    angle = halfAngle * 2

    # The rhombus from the border tip to the path tip
    rhombusSide = hb / Math.sin angle

    distanceBetweenTips = 2 * rhombusSide * Math.cos halfAngle
    stemLength = hb + outerStemLength - distanceBetweenTips

    throw new Error "Sorry but your stemLength / stemBase ratio is strange." if stemLength < 0

    # Now calculate the new base
    stemBase = (Math.tan(halfAngle) * stemLength) * 2

    { stemLength: stemLength, stemBase: stemBase }



  # Turns a color string into a possible gradient
  _getColor: (ctx, dimensions, color, horizontal = no) ->

    # There is no comma so just return
    return color if typeof color == "string"

    # Create gradient
    if horizontal
      gradient = ctx.createLinearGradient 0, 0, dimensions.width, 0
    else
      gradient = ctx.createLinearGradient 0, 0, 0, dimensions.height

    for colorStop, i in color
      gradient.addColorStop colorStop[0], colorStop[1]

    gradient


  _searchAndActivateCloseButtons: ->
    for element in @adapter.findAll @container, ".#{@class.close}"
      @hideTriggers.push
        element: @adapter.wrap element
        event: "click"

    # Creating the observers for the new close buttons
    @_setupObservers "-showing", "showing" if @currentObservers.showing
    @_setupObservers "-visible", "visible" if @currentObservers.visible

  _activateFirstInput: ->
    input = @adapter.unwrap @adapter.find @container, "input, textarea"
    input?.focus?()

  # Calls reposition() everytime the mouse moves
  _followMousePosition: -> Opentip._observeMousePosition @bound.reposition unless @options.fixed

  # Removes observer
  _stopFollowingMousePosition: -> Opentip._stopObservingMousePosition @bound.reposition unless @options.fixed


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

  _loadAjax: ->
    return if @loading

    @loaded = no
    @loading = yes

    @adapter.addClass @container, @class.loading
    # This will reset the dimensions so it has to be AFTER the `addClass` call
    # since the `loading` class might show a loading indicator that will change
    # the dimensions of the tooltip
    @setContent ""

    @debug "Loading content from #{@options.ajax}"

    @adapter.ajax
      url: @options.ajax
      method: @options.ajaxMethod
      onSuccess: (responseText) =>
        @debug "Loading successful."
        # This has to happen before setting the content since loading indicators
        # may still be visible.
        @adapter.removeClass @container, @class.loading
        @setContent responseText
      onError: (error) =>
        message = @options.ajaxErrorMessage
        @debug message, error
        @setContent message
        @adapter.addClass @container, @class.ajaxError
      onComplete: =>
        @adapter.removeClass @container, @class.loading
        @loading = no
        @loaded = yes
        @_searchAndActivateCloseButtons()
        @_activateFirstInput()
        @reposition()

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
    if element.style[prop]?
      element.style[prop] = value
    else
      for vendor in vendors
        vendorProp = "#{@ucfirst vendor}#{@ucfirst prop}"
        element.style[vendorProp] = value if element.style[vendorProp]?

# Defers the call
Opentip::defer = (func) -> setTimeout func, 0

# Changes seconds to milliseconds
Opentip::setTimeout = (func, seconds) -> setTimeout func, if seconds then seconds * 1000 else 0

# Turns only the first character uppercase
Opentip::ucfirst = (string) ->
  return "" unless string?
  string.charAt(0).toUpperCase() + string.slice(1)

# Converts a camelized string into a dasherized one
Opentip::dasherize = (string) ->
  string.replace /([A-Z])/g, (_, character) -> "-#{character.toLowerCase()}"





# Mouse position stuff.

mousePositionObservers = [ ]
mousePosition = { x: 0, y: 0 }

mouseMoved = (e) ->
  mousePosition = Opentip.adapter.mousePosition e
  observer() for observer in mousePositionObservers

Opentip.followMousePosition = -> Opentip.adapter.observe document.body, "mousemove", mouseMoved


# Called by opentips if they want updates on mouse position
Opentip._observeMousePosition = (observer) ->
  mousePositionObservers.push observer

Opentip._stopObservingMousePosition = (removeObserver) ->
  mousePositionObservers = (observer for observer in mousePositionObservers when observer != removeObserver)





# Every position is converted to this class
class Opentip.Joint
  # Accepts pointer in nearly every form.
  #
  #   - "top left"
  #   - "topLeft"
  #   - "top-left"
  #   - "RIGHT to TOP"
  # 
  # All that counts is that the words top, bottom, left or right are present.
  #
  # It also accepts a Pointer object, creating a new object then
  constructor: (pointerString) ->
    return unless pointerString?

    if pointerString instanceof Opentip.Joint
      pointerString = pointerString.toString()

    @set pointerString

    @

  set: (string) ->
    string = string.toLowerCase()

    @setHorizontal string
    @setVertical string

    @

  setHorizontal: (string) ->
    valid = [ "left", "center", "right" ]
    @horizontal = i.toLowerCase() for i in valid when ~string.indexOf i
    @horizontal = "center" unless @horizontal?

    for i in valid
      this[i] = if @horizontal == i then i else undefined

  setVertical: (string) ->
    valid = [ "top", "middle", "bottom" ]
    @vertical = i.toLowerCase() for i in valid when ~string.indexOf i
    @vertical = "middle" unless @vertical?
    for i in valid
      this[i] = if @vertical == i then i else undefined



  # Checks if two pointers point in the same direction
  eql: (pointer) ->
    pointer? and @horizontal == pointer.horizontal and @vertical == pointer.vertical

  # Turns topLeft into bottomRight
  flip: ->
    positionIdx = Opentip.position[@toString yes]
    # There are 8 positions, and smart as I am I layed them out in a circle.
    flippedIndex = (positionIdx + 4) % 8
    @set Opentip.positions[flippedIndex]
    @

  toString: (camelized = no) ->
    vertical = if @vertical == "middle" then "" else @vertical
    horizontal = if @horizontal == "center" then "" else @horizontal

    if vertical and horizontal
      if camelized then horizontal = Opentip::ucfirst horizontal
      else horizontal = " #{horizontal}"

    "#{vertical}#{horizontal}"


# Returns true if top and left are equal
Opentip::_positionsEqual = (posA, posB) ->
  posA? and posB? and posA.left == posB.left and posA.top == posB.top

# Returns true if width and height are equal
Opentip::_dimensionsEqual = (dimA, dimB) ->
  dimA? and dimB? and dimA.width == dimB.width and dimA.height == dimB.height


# Just forwards to console.debug if Opentip.debug is true and console.debug exists.
Opentip::debug = (args...) ->
  if Opentip.debug and console?.debug?
    args.unshift "##{@id} |"
    console.debug args... 



# Startup
# -------

Opentip.findElements = ->
  adapter = Opentip.adapter

  # Go through all elements with `data-ot="[...]"`
  for element in adapter.findAll document.body, "[data-ot]"
    options = { }

    content = adapter.data element, "ot"

    if content in [ "", "true", "yes"]
      # Take the content from the title attribute
      content = adapter.attr element, "title"
      adapter.attr element, "title", ""

    content = content || ""

    for optionName of Opentip.styles.standard
      optionValue = adapter.data element, "ot#{Opentip::ucfirst optionName}"
      if optionValue?
        if optionValue in [ "yes", "true", "on" ] then optionValue = true 
        else if optionValue in [ "no", "false", "off" ] then optionValue = false
        options[optionName] = optionValue

    new Opentip element, content, options

# Publicly available
# ------------------

Opentip.version = "2.4.6"

Opentip.debug = off

Opentip.lastId = 0

Opentip.lastZIndex = 100


Opentip.tips = [ ]

Opentip._abortShowingGroup = (group, originatingOpentip) ->
  for opentip in Opentip.tips
    opentip._abortShowing() if opentip != originatingOpentip and opentip.options.group == group

Opentip._hideGroup = (group, originatingOpentip) ->
  for opentip in Opentip.tips
    opentip.hide() if opentip != originatingOpentip and opentip.options.group == group

# A list of possible adapters. Used for testing
Opentip.adapters = { }

# The current adapter used.
Opentip.adapter = null

firstAdapter = yes
Opentip.addAdapter = (adapter) ->
  Opentip.adapters[adapter.name] = adapter
  if firstAdapter
    Opentip.adapter = adapter
    adapter.domReady Opentip.findElements
    adapter.domReady Opentip.followMousePosition
    firstAdapter = no

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
    # This config is not based on anything
    extends: null

    # This style also contains all default values for other styles.
    #
    # Following abbreviations are used:
    #
    # - `POINTER` : a string that contains at least one of top, bottom, right or left
    # - `OFFSET` : [ XVALUE, YVALUE ] (integers)
    # - `ELEMENT` : element or element id

    # Will be set if provided in constructor
    title: undefined

    # Whether the provided title should be html escaped
    escapeTitle: yes

    # Whether the content should be html escaped
    escapeContent: no

    # The class name to be added to the HTML element
    className: "standard"

    # - `false` (no stem)
    # - `true` (stem at tipJoint position)
    # - `POINTER` (for stems in other directions)
    stem: yes

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
    # - `"outside"` Somewhere outside the trigger or tip (Makes really only sense with the click event)
    # - `ELEMENT`
    #
    # This is just a shortcut, and will be added to hideTriggers if hideTrigger
    # is an empty array
    hideTrigger: "trigger"

    # An array of hideTriggers.
    hideTriggers: [ ]

    # - eventname (eg: `"click"`)
    # - array of event strings if multiple hideTriggers
    # - `null` (let Opentip decide)
    hideOn: null

    # Removes all HTML elements from DOM when an Opentip is hidden if true
    removeElementsOnHide: off

    # `OFFSET`
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
    stemLength: 5

    # integer
    stemBase: 8

    # `POINTER`
    tipJoint: "top left"

    # - `null` (no target, opentip uses mouse as target)
    # - `true` (target is the triggerElement)
    # - `ELEMENT` (for another element)
    target: null 

    # - `POINTER` (Ignored if target == `null`)
    # - `null` (targetJoint is the opposite of tipJoint)
    targetJoint: null 

    # If off and the content gets downloaded with AJAX, it will be downloaded
    # every time the tooltip is shown. If the content is a function, the function
    # will be executed every time.
    cache: on

    # ajaxCache: on # Deprecated in favor of cache.

    # AJAX URL
    # Set to `false` if no AJAX or `true` if it's attached to an `<a />`
    # element. In the latter case the `href` attribute will be used.
    ajax: off

    # Which method should AJAX use.
    ajaxMethod: "GET"

    # The message that gets displayed if the content couldn't be downloaded.
    ajaxErrorMessage: "There was a problem downloading the content."

    # You can group opentips together. So when a tooltip shows, it looks if there are others in the same group, and hides them.
    group: null

    # Will be set automatically in constructor
    style: null

    # The background color of the tip
    background: "#fff18f"

    # Whether the gradient should be horizontal.
    backgroundGradientHorizontal: no

    # Positive values offset inside the tooltip
    closeButtonOffset: [ 5, 5 ]

    # The little circle that stick out of a tip
    closeButtonRadius: 7

    # Size of the cross
    closeButtonCrossSize: 4

    # Color of the cross
    closeButtonCrossColor: "#d2c35b"

    # The stroke width of the cross
    closeButtonCrossLineWidth: 1.5

    # You will most probably never want to change this.
    # It specifies how many pixels the invisible <a> element should be larger
    # than the actual cross
    closeButtonLinkOverscan: 6

    # Border radius...
    borderRadius: 5

    # Set to 0 or false if you don't want a border
    borderWidth: 1

    # Normal CSS value
    borderColor: "#f2e37b"

    # Set to false if you don't want a shadow
    shadow: yes

    # How the shadow should be blurred. Set to 0 if you want a hard drop shadow 
    shadowBlur: 10

    # Shadow offset...
    shadowOffset: [ 3, 3 ]

    # Shadow color...
    shadowColor: "rgba(0, 0, 0, 0.1)"

  glass:
    extends: "standard"
    className: "glass"
    background: [
      [ 0, "rgba(252, 252, 252, 0.8)" ]
      [ 0.5, "rgba(255, 255, 255, 0.8)" ]
      [ 0.5, "rgba(250, 250, 250, 0.9)" ]
      [ 1, "rgba(245, 245, 245, 0.9)" ]
    ]
    borderColor: "#eee"
    closeButtonCrossColor: "rgba(0, 0, 0, 0.2)"
    borderRadius: 15
    closeButtonRadius: 10
    closeButtonOffset: [ 8, 8 ]


  dark:
    extends: "standard"
    className: "dark"
    borderRadius: 13
    borderColor: "#444"

    closeButtonCrossColor: "rgba(240, 240, 240, 1)"

    shadowColor: "rgba(0, 0, 0, 0.3)"
    shadowOffset: [ 2, 2 ]
    background: [
      [ 0, "rgba(30, 30, 30, 0.7)" ]
      [ 0.5, "rgba(30, 30, 30, 0.8)" ]
      [ 0.5, "rgba(10, 10, 10, 0.8)" ]
      [ 1, "rgba(10, 10, 10, 0.9)" ]
    ]

  alert:
    extends: "standard"
    className: "alert"
    borderRadius: 1
    borderColor: "#AE0D11"

    closeButtonCrossColor: "rgba(255, 255, 255, 1)"

    shadowColor: "rgba(0, 0, 0, 0.3)"
    shadowOffset: [ 2, 2 ]
    background: [
      [ 0, "rgba(203, 15, 19, 0.7)" ]
      [ 0.5, "rgba(203, 15, 19, 0.8)" ]
      [ 0.5, "rgba(189, 14, 18, 0.8)" ]
      [ 1, "rgba(179, 14, 17, 0.9)" ]
    ]


# Change this to the style name you want all your tooltips to have as default.
Opentip.defaultStyle = "standard"



if module?
  module.exports = Opentip
else
  window.Opentip = Opentip


