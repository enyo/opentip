
$ = ender

describe "Opentip - Appearing", ->
  adapter = Opentip.adapters.native
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    Opentip.adapter = adapter
    triggerElementExists = yes

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip.deactivate()

    $(".opentip-container").remove()

  describe "prepareToShow()", ->
    beforeEach ->
      triggerElementExists = no
      opentip = new Opentip adapter.create("<div></div>"), "Test", delay: 0
      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

    it "should always abort a hiding process", ->
      sinon.stub opentip, "_abortHiding"
      opentip.prepareToShow()
      expect(opentip._abortHiding.callCount).to.be 1

    it "even when aborting because it's already visible", ->
      sinon.stub opentip, "_abortHiding"
      opentip.visible = yes
      opentip.prepareToShow()
      expect(opentip._abortHiding.callCount).to.be 1

    it "should abort when already visible", ->
      expect(opentip.preparingToShow).to.not.be.ok()
      opentip.visible = yes
      opentip.prepareToShow()
      expect(opentip.preparingToShow).to.not.be.ok()
      opentip.visible = no
      opentip.prepareToShow()
      expect(opentip.preparingToShow).to.be.ok()

    it "should log that it's preparing to show", ->
      sinon.stub opentip, "debug"
      opentip.prepareToShow()
      expect(opentip.debug.callCount).to.be 1

    it "should setup observers for 'showing'", ->
      sinon.stub opentip, "_setupObservers"
      opentip.prepareToShow()
      expect(opentip._setupObservers.callCount).to.be 1
      expect(opentip._setupObservers.getCall(0).args[0]).to.be "showing"

    it "should start following mouseposition", ->
      sinon.stub opentip, "_followMousePosition"
      opentip.prepareToShow()
      expect(opentip._followMousePosition.callCount).to.be 1

    it "should reposition itself «On se redresse!»", ->
      sinon.stub opentip, "reposition"
      opentip.prepareToShow()
      expect(opentip.reposition.callCount).to.be 1

    it "should call show() after the specified delay (50ms)", (done) ->
      opentip.options.delay = 0.05
      sinon.stub opentip, "show", -> done()
      opentip.prepareToShow()

  describe "show()", ->
    beforeEach ->
      opentip = new Opentip adapter.create("<div></div>"), "Test", delay: 0
      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

    it "should clear all timeouts", ->
      triggerElementExists = no
      sinon.stub opentip, "_clearTimeouts"
      opentip.show()
      expect(opentip._clearTimeouts.callCount).to.be.above 0
    it "should clear all timeouts even if alrady visible", ->
      triggerElementExists = no
      sinon.stub opentip, "_clearTimeouts"
      opentip.visible = yes
      opentip.show()
      expect(opentip._clearTimeouts.callCount).to.be 1

    it "should abort if already visible", ->
      triggerElementExists = no
      sinon.stub opentip, "debug"
      opentip.visible = yes
      opentip.show()
      expect(opentip.debug.callCount).to.be 0

    it "should log that it's showing", ->
      sinon.stub opentip, "debug"
      opentip.show()
      expect(opentip.debug.callCount).to.be.above 1
      expect(opentip.debug.args[0][0]).to.be "Showing now."

    it "should set visible to true and preparingToShow to false", ->
      opentip.preparingToShow = yes
      opentip.show()
      expect(opentip.visible).to.be.ok()
      expect(opentip.preparingToShow).to.not.be.ok()

  describe "events", ->

    element = ""

    beforeEach ->
      element = document.createElement "div"

    testEvent = (opentip, event, done) ->
      expect(opentip.visible).to.not.be.ok()
      $(element).trigger event
      expect(opentip.preparingToShow).to.be.ok()
      expect(opentip.visible).to.not.be.ok()
      setTimeout ->
        try
          expect(opentip.visible).to.be.ok()
          done()
        catch e
          done e
      , 2

    for event in [ "click", "mouseover", "focus" ]
      it "should show on #{event}", (done) ->
        opentip = new Opentip element, "test", delay: 0, showOn: event
        sinon.stub opentip, "_triggerElementExists", -> triggerElementExists
        testEvent opentip, event, done

  describe "visible", ->
    enderElement = null
    element = null
    span = null
    beforeEach ->
      enderElement = $ "<div><div><span></span></div></div>"
      span = enderElement.find "span"
      element = enderElement.get(0)

      opentip = new Opentip element, "test",
        delay: 0
        hideDelay: 0
        showOn: "click"
        hideOn: "mouseout"

      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

    it "should not hide when hovering child elements and hideOn == mouseout", (done) ->
      expect(opentip.visible).to.not.be.ok()
      enderElement.trigger "click"
      expect(opentip.preparingToShow).to.be.ok()
      expect(opentip.visible).to.not.be.ok()
      setTimeout ->
        try
          expect(opentip.visible).to.be.ok()
          enderElement.trigger "mouseout"
          enderElement.trigger "mouseover"
          setTimeout ->
            try
              expect(opentip.visible).to.be.ok()
            catch e
              done e
          , 4
          done()
        catch e
          done e
      , 4

