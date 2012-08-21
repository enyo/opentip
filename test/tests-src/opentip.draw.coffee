
$ = ender

describe "Opentip - Drawing", ->
  adapter = Opentip.adapters.native
  opentip = null

  beforeEach ->
    Opentip.adapter = adapter

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip.deactivate()
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
