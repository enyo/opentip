
$ = jQuery

describe "Opentip - Appearing", ->
  adapter = Opentip.adapter
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    triggerElementExists = yes

  afterEach ->
    if opentip
      opentip[prop]?.restore?() for own prop of opentip
      opentip.deactivate()

    $(".opentip-container").remove()

  describe "prepareToShow()", ->
    beforeEach ->
      triggerElementExists = no
      opentip = new Opentip adapter.create("<div></div>"), "Test", delay: 0
      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

    it "should call _setup if no container yet", ->
      sinon.spy opentip, "_setup"
      opentip.prepareToShow()
      opentip.prepareToShow()
      expect(opentip._setup.calledOnce).to.be.ok()

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
      expect(opentip.debug.callCount).to.be 2
      expect(opentip.debug.getCall(0).args[0]).to.be "Showing in 0s."
      expect(opentip.debug.getCall(1).args[0]).to.be "Setting up the tooltip."

    it "should setup observers for 'showing'", ->
      sinon.stub opentip, "_setupObservers"
      opentip.prepareToShow()
      expect(opentip._setupObservers.callCount).to.be 1
      expect(opentip._setupObservers.getCall(0).args[0]).to.be "-hidden"
      expect(opentip._setupObservers.getCall(0).args[1]).to.be "-hiding"
      expect(opentip._setupObservers.getCall(0).args[2]).to.be "showing"

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

    it "should call _setup if no container yet", ->
      sinon.spy opentip, "_setup"
      opentip.show()
      opentip.show()
      expect(opentip._setup.calledOnce).to.be.ok()

    it "should clear all timeouts", ->
      triggerElementExists = no
      sinon.stub opentip, "_clearTimeouts"
      opentip.show()
      expect(opentip._clearTimeouts.callCount).to.be.above 0
    it "should not clear all timeouts when already visible", ->
      triggerElementExists = no
      sinon.stub opentip, "_clearTimeouts"
      opentip.visible = yes
      opentip.show()
      expect(opentip._clearTimeouts.callCount).to.be 0

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

    it "should use _ensureViewportContaintment if options.containInViewport", ->
      sinon.spy opentip, "_ensureViewportContainment"
      sinon.stub opentip, "getPosition", -> x: 0, y: 0
      opentip.show()
      expect(opentip._ensureViewportContainment.callCount).to.be.above 1

    it "should not use _ensureViewportContaintment if !options.containInViewport", ->
      opentip.options.containInViewport = no
      sinon.stub opentip, "_ensureViewportContainment"
      opentip.show()
      expect(opentip._ensureViewportContainment.callCount).to.be 0

  describe "grouped Opentips", ->
    it "should hide all other opentips", ->
      Opentip.tips = [ ]
      opentip = new Opentip adapter.create("<div></div>"), "Test", { delay: 0, group: "test" }
      opentip2 = new Opentip adapter.create("<div></div>"), "Test", { delay: 0, group: "test" }
      opentip3 = new Opentip adapter.create("<div></div>"), "Test", { delay: 0, group: "test" }
      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists
      sinon.stub opentip2, "_triggerElementExists", -> triggerElementExists
      sinon.stub opentip3, "_triggerElementExists", -> triggerElementExists

      opentip.show()
      expect(opentip.visible).to.be.ok()
      expect(opentip2.visible).to.not.be.ok()
      expect(opentip3.visible).to.not.be.ok()
      opentip2.show()
      expect(opentip.visible).to.not.be.ok()
      expect(opentip2.visible).to.be.ok()
      expect(opentip3.visible).to.not.be.ok()
      opentip3.show()
      expect(opentip.visible).to.not.be.ok()
      expect(opentip2.visible).to.not.be.ok()
      expect(opentip3.visible).to.be.ok()

      opentip.deactivate()
      opentip2.deactivate()
      opentip3.deactivate()

    it "should abort showing other opentips", ->
      Opentip.tips = [ ]
      opentip = new Opentip adapter.create("<div></div>"), "Test", { delay: 1000, group: "test" }
      opentip2 = new Opentip adapter.create("<div></div>"), "Test", { delay: 1000, group: "test" }
      opentip3 = new Opentip adapter.create("<div></div>"), "Test", { delay: 1000, group: "test" }
      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists
      sinon.stub opentip2, "_triggerElementExists", -> triggerElementExists
      sinon.stub opentip3, "_triggerElementExists", -> triggerElementExists

      opentip.prepareToShow()
      expect(opentip.visible).to.not.be.ok()
      expect(opentip.preparingToShow).to.be.ok()
      expect(opentip2.visible).to.not.be.ok()
      expect(opentip2.preparingToShow).to.not.be.ok()

      opentip2.prepareToShow()
      expect(opentip.visible).to.not.be.ok()
      expect(opentip.preparingToShow).to.not.be.ok()
      expect(opentip2.visible).to.not.be.ok()
      expect(opentip2.preparingToShow).to.be.ok()

      opentip3.show()
      expect(opentip.visible).to.not.be.ok()
      expect(opentip.preparingToShow).to.not.be.ok()
      expect(opentip2.visible).to.not.be.ok()
      expect(opentip2.preparingToShow).to.not.be.ok()

      opentip.deactivate()
      opentip2.deactivate()
      opentip3.deactivate()

  describe "events", ->

    element = ""

    beforeEach ->
      element = document.createElement "div"

    testEvent = (opentip, event, done) ->
      expect(opentip.visible).to.not.be.ok()

      Test.triggerEvent element, event

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

  describe "hide", ->
    it "should remove HTML elements if removeElementsOnHide: true", (done) ->
      opentip = new Opentip adapter.create("<div></div>"), "Test", { delay: 0, removeElementsOnHide: yes, hideEffectDuration: 0, hideDelay: 0 }
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect($("#opentip-#{opentip.id}").length).to.be 1
      opentip.hide()

      setTimeout (->
        expect($("#opentip-#{opentip.id}").length).to.be 0
        opentip.show()
        expect($("#opentip-#{opentip.id}").length).to.be 1
        opentip = null
        done()
      ), 100

  describe "visible", ->
    $element = null
    element = null
    span = null
    beforeEach ->
      $element = $ "<div><div><span></span></div></div>"
      span = $element.find "span"
      element = $element[0]


    # it "should not hide when hovering child elements and hideOn == mouseout", (done) ->
    #   opentip = new Opentip element, "test",
    #     delay: 0
    #     hideDelay: 0
    #     showOn: "click"
    #     hideOn: "mouseout"

    #   sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

    #   expect(opentip.visible).to.not.be.ok()
    #   enderElement.trigger "click"
    #   expect(opentip.preparingToShow).to.be.ok()
    #   expect(opentip.visible).to.not.be.ok()
    #   setTimeout ->
    #     try
    #       expect(opentip.visible).to.be.ok()
    #       enderElement.trigger "mouseout"
    #       enderElement.trigger "mouseover"
    #       setTimeout ->
    #         try
    #           expect(opentip.visible).to.be.ok()
    #         catch e
    #           done e
    #       , 4
    #       done()
    #     catch e
    #       done e
    #   , 4

    it "should activate all hide buttons", (done) ->
      closeClass = Opentip::class.close
      opentip = new Opentip element, """<a class="#{closeClass}">close</a>""",
        escape: no
        delay: 0
        hideDelay: 0
        hideTrigger: "closeButton"
        hideOn: "click"

      sinon.stub opentip, "_triggerElementExists", -> triggerElementExists
      sinon.stub opentip, "prepareToHide"

      opentip.prepareToShow()
    
    
      setTimeout ->
        try
          closeButtons = $(opentip.container).find(".#{closeClass}")
          expect(closeButtons.length).to.be 2 # The close button created by opentip and the one in content

          expect(opentip.prepareToHide.callCount).to.be 0
        catch e
          done e
          return

        Test.triggerEvent closeButtons[0], "click"

        setTimeout ->
          try
            expect(opentip.prepareToHide.callCount).to.be 1
            done()
          catch e
            done e
        , 4
      4



