
$ = ender

describe "Opentip - Drawing", ->
  adapter = Opentip.adapters.native
  opentip = null

  beforeEach ->
    Opentip.adapter = adapter

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
      opentip.backgroundCanvas = document.createElement "canvas"
      opentip.redraw = on
      opentip._draw()
      expect(opentip.debug.callCount).to.be.above 0
      expect(opentip.debug.args[0][0]).to.be "Drawing background."

    it "should set the correct width of the canvas"
    it "should set the correct offset of the canvas"

  describe "with close button", ->
    options = { }

    beforeEach ->
      options = 
        delay: 0
        stem: no
        hideTrigger: "closeButton"
        closeButtonOffset: [ 0, 10 ]
        closeButtonCrossSize: 10
        closeButtonLinkOverscan: 5
        borderWidth: 0

    createAndShowTooltip = ->
      opentip = new Opentip adapter.create("<div></div>"), "Test", options
      opentip._storeAndLockDimensions = -> @dimensions = { width: 200, height: 100 }
      opentip._ensureViewportContainment = (e, position) ->
        {
          position: position
          stem: @options.stem
        }
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect(opentip._dimensionsEqual opentip.dimensions, { width: 200, height: 100 }).to.be.ok()
      opentip


    it "should position the close link when no border", ->
      options.borderWidth = 0
      options.closeButtonOffset = [ 0, 10 ]
      options.closeButtonCrossSize = 10

      createAndShowTooltip()

      enderElement = $(adapter.unwrap opentip.closeButtonElement)

      expect(enderElement.css "left").to.be "190px"
      expect(enderElement.css "top").to.be "0px"
      expect(enderElement.css "width").to.be "20px" # cross size + overscan*2
      expect(enderElement.css "height").to.be "20px"

    it "should position the close link when border and different overscan", ->
      options.borderWidth = 20
      options.closeButtonOffset = [ 0, 10 ]
      options.closeButtonCrossSize = 10
      options.closeButtonLinkOverscan = 10

      createAndShowTooltip()

      enderElement = $(adapter.unwrap opentip.closeButtonElement)

      expect(enderElement.css "left").to.be "185px"
      expect(enderElement.css "top").to.be "-5px"
      expect(enderElement.css "width").to.be "30px" # cross size + overscan*2
      expect(enderElement.css "height").to.be "30px"

    it "should position the close link with different offsets and overscans", ->
      options.closeButtonOffset = [ 100, 5 ]
      options.closeButtonCrossSize = 10
      options.closeButtonLinkOverscan = 0

      createAndShowTooltip()

      enderElement = $(adapter.unwrap opentip.closeButtonElement)

      expect(enderElement.css "left").to.be "95px"
      expect(enderElement.css "top").to.be "0px"
      expect(enderElement.css "width").to.be "10px" # cross size + overscan*2
      expect(enderElement.css "height").to.be "10px"

    it "should correctly position the close link on the left when stem on top right", ->
      options.closeButtonOffset = [ 20, 17 ]
      options.closeButtonCrossSize = 12
      options.closeButtonLinkOverscan = 5
      options.stem = "top right"

      opentip = createAndShowTooltip()

      enderElement = $(adapter.unwrap opentip.closeButtonElement)

      expect(opentip.options.stem.toString()).to.be "top right"

      expect(enderElement.css "left").to.be "9px"
      expect(enderElement.css "top").to.be "6px"
      expect(enderElement.css "width").to.be "22px" # cross size + overscan*2
      expect(enderElement.css "height").to.be "22px"


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


