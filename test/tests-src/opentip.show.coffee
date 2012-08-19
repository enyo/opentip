
$ = ender

describe "Opentip", ->
  adapter = Opentip.adapters.native
  beforeEach ->
    Opentip.adapter = adapter

  describe "prepareToShow()", ->
    opentip = null
    beforeEach ->
      opentip = new Opentip adapter.create("<div></div>"), "Test"
    afterEach ->
      opentip[prop].restore?() for prop of opentip

    it "should always abort a hiding process", ->
      sinon.stub opentip, "_abortHiding"
      opentip.prepareToShow()
      expect(opentip._abortHiding.callCount).to.be 1
    it "even when aborting because it's already visible", ->
      sinon.stub opentip, "_abortHiding"
      opentip.visible = yes
      opentip.prepareToShow()
      expect(opentip._abortHiding.callCount).to.be 1



