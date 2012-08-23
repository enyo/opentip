
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
      triggerElementExists = no
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


