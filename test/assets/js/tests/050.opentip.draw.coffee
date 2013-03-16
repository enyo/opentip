
$ = jQuery

describe "Opentip - Drawing", ->
  adapter = Opentip.adapter
  opentip = null


  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip?.deactivate?()
    $(".opentip-container").remove()

  describe "_draw()", ->
    beforeEach ->
      opentip = new Opentip adapter.create("<div></div>"), "Test", delay: 0
      sinon.stub opentip, "_triggerElementExists", -> yes

    it "should abort if @redraw not set", ->
      sinon.stub opentip, "debug"
      opentip.backgroundCanvas = document.createElement "canvas"
      opentip.redraw = off
      opentip._draw()
      expect(opentip.debug.callCount).to.be 0

    it "should abort if no canvas not set", ->
      sinon.stub opentip, "debug"
      opentip.redraw = on
      opentip._draw()
      expect(opentip.debug.callCount).to.be 0

    it "should draw if canvas and @redraw", ->
      sinon.stub opentip, "debug"
      opentip._setup()
      opentip.backgroundCanvas = document.createElement "canvas"
      opentip.redraw = on
      opentip._draw()
      expect(opentip.debug.callCount).to.be.above 0
      expect(opentip.debug.args[1][0]).to.be "Drawing background."

    it "should add the stem classes", ->
      sinon.stub opentip, "debug"
      opentip._setup()
      opentip.backgroundCanvas = document.createElement "canvas"

      opentip.currentStem = new Opentip.Joint "bottom left"
      opentip.redraw = on
      opentip._draw()

      unwrappedContainer = Opentip.adapter.unwrap(opentip.container)
      expect(unwrappedContainer.classList.contains("stem-bottom")).to.be.ok()
      expect(unwrappedContainer.classList.contains("stem-left")).to.be.ok()

      opentip.currentStem = new Opentip.Joint "right middle"
      opentip.redraw = on
      opentip._draw()

      expect(unwrappedContainer.classList.contains("stem-bottom")).not.to.be.ok()
      expect(unwrappedContainer.classList.contains("stem-left")).not.to.be.ok()
      expect(unwrappedContainer.classList.contains("stem-middle")).to.be.ok()
      expect(unwrappedContainer.classList.contains("stem-right")).to.be.ok()

    it "should set the correct width of the canvas"
    it "should set the correct offset of the canvas"

  describe "with close button", ->
    options = { }
    element = null
    beforeEach ->
      element = $("<div />")
      $(document.body).append(element)
      sinon.stub Opentip.adapter, "dimensions", -> { width: 199, height: 100 } # -1 because of the firefox bug
      options = 
        delay: 0
        stem: no
        hideTrigger: "closeButton"
        closeButtonRadius: 20
        closeButtonOffset: [ 0, 10 ]
        closeButtonCrossSize: 10
        closeButtonLinkOverscan: 5
        borderWidth: 0
        containInViewport: no

    afterEach ->
      element.remove()
      Opentip.adapter.dimensions.restore()

    createAndShowTooltip = ->
      opentip = new Opentip element.get(0), "Test", options
      # opentip._storeAndLockDimensions = -> @dimensions = { width: 200, height: 100 }
      # opentip._ensureViewportContainment = (e, position) ->
      #   {
      #     position: position
      #     stem: @options.stem
      #   }
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect(opentip._dimensionsEqual opentip.dimensions, { width: 200, height: 100 }).to.be.ok()
      opentip


    it "should position the close link when no border", ->
      options.borderWidth = 0
      options.closeButtonOffset = [ 0, 10 ]

      createAndShowTooltip()

      el = adapter.unwrap opentip.closeButtonElement

      expect(el.style.left).to.be "190px"
      expect(el.style.top).to.be "0px"
      expect(el.style.width).to.be "20px" # cross size + overscan*2
      expect(el.style.height).to.be "20px"

    it "should position the close link when border and different overscan", ->
      options.borderWidth = 1
      options.closeButtonLinkOverscan = 10

      createAndShowTooltip()

      el = adapter.unwrap opentip.closeButtonElement

      expect(el.style.left).to.be "185px"
      expect(el.style.top).to.be "-5px"
      expect(el.style.width).to.be "30px" # cross size + overscan*2
      expect(el.style.height).to.be "30px"

    it "should position the close link with different offsets and overscans", ->
      options.closeButtonOffset = [ 10, 5 ]
      options.closeButtonCrossSize = 10
      options.closeButtonLinkOverscan = 0

      createAndShowTooltip()

      el = adapter.unwrap opentip.closeButtonElement

      expect(el.style.left).to.be "185px"
      expect(el.style.top).to.be "0px"
      expect(el.style.width).to.be "10px" # cross size + overscan*2
      expect(el.style.height).to.be "10px"

    it "should correctly position the close link on the left when stem on top right", ->
      options.closeButtonOffset = [ 20, 17 ]
      options.closeButtonCrossSize = 12
      options.closeButtonLinkOverscan = 5
      options.stem = "top right"

      opentip = createAndShowTooltip()

      el = adapter.unwrap opentip.closeButtonElement

      expect(opentip.options.stem.toString()).to.be "top right"

      expect(el.style.left).to.be "9px"
      expect(el.style.top).to.be "6px"
      expect(el.style.width).to.be "22px" # cross size + overscan*2
      expect(el.style.height).to.be "22px"


  describe "_getPathStemMeasures()", ->
    it "should just return the same measures if borderWidth is 0", ->
      {stemBase, stemLength} = opentip._getPathStemMeasures 6, 10, 0
      expect(stemBase).to.be 6
      expect(stemLength).to.be 10
    it "should properly calculate the pathStem information if borderWidth > 0", ->
      {stemBase, stemLength} = opentip._getPathStemMeasures 6, 10, 3
      expect(stemBase).to.be 3.767908047326835
      expect(stemLength).to.be 6.2798467455447256
    it "should throw an exception if the measures aren't right", ->
      expect(-> opentip._getPathStemMeasures 6, 10, 40).to.throwError()

  describe "_getColor()", ->
    dimensions = width: 200, height: 100
    
    cavans = document.createElement "canvas"
    ctx = cavans.getContext "2d"
    gradient = ctx.createLinearGradient 0, 0, 1, 1

    ctx = sinon.stub ctx

    gradient = sinon.stub gradient
    ctx.createLinearGradient.returns gradient

    it "should just return the hex color", ->
      expect(Opentip::_getColor ctx, dimensions, "#f00").to.be "#f00"

    it "should just return rgba color", ->
      expect(Opentip::_getColor ctx, dimensions, "rgba(0, 0, 0, 0.3)").to.be "rgba(0, 0, 0, 0.3)"

    it "should just return named color", ->
      expect(Opentip::_getColor ctx, dimensions, "red").to.be "red"

    it "should create and return gradient", ->
      color = Opentip::_getColor ctx, dimensions, [ [0, "black"], [1, "white"] ]
      expect(gradient.addColorStop.callCount).to.be 2
      expect(color).to.be gradient


