
$ = ender

describe "Opentip", ->
  describe "debug()", ->
    consoleDebug = console.debug
    beforeEach -> sinon.stub console, "debug"
    afterEach -> console.debug.restore()

    it "should only debug when debugging == true", ->
      Opentip.debugging = off
      Opentip::debug "test"
      expect(console.debug.called).to.be.false
      Opentip.debugging = on
      Opentip::debug "test"
      expect(console.debug.called).to.be.true

  describe "constructor()", ->
    before ->
      Opentip.adapter = Opentip.adapters.native
    it "arguments should be optional", ->
      opentip = new Opentip "div", "content"
      expect(opentip.content).to.equal "content"
      expect(opentip.triggerElement).to.equal "div"

      opentip = new Opentip "div", "content", "title", { hideOn: "click" }
      expect(opentip.content).to.equal "content"
      expect(opentip.triggerElement).to.equal "div"
      expect(opentip.options.hideOn).to.equal "click"
      expect(opentip.options.title).to.equal "title"

      opentip = new Opentip "div", { hideOn: "click" }
      expect(opentip.triggerElement).to.equal "div"
      expect(opentip.options.hideOn).to.equal "click"
      expect(opentip.content).to.equal ""
      expect(opentip.options.title).to.equal undefined

    it "should use the href attribute if AJAX and an A element", ->
      element = $("""<a href="http://testlink">link</a>""").get(0)
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.be.a "object"
      expect(opentip.options.ajax.url).to.equal "http://testlink"
    it "should disable AJAX if neither URL or a link HREF is provided", ->
      element = $("""<div>text</div>""").get(0)
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.not.be.ok()

    it "should disable a link if the event is onClick", ->
      sinon.spy Opentip.adapter, "observe"
      element = $("""<a href="http://testlink">link</a>""").get(0)
      opentip = new Opentip element, showOn: "click"

      expect(Opentip.adapter.observe.calledOnce).to.be.ok()
      expect(Opentip.adapter.observe.getCall(0).args[1]).to.equal "click"
      expect(Opentip.adapter.observe.getCall(0).args[3]).to.be.ok()

      Opentip.adapter.observe.restore()

    it "should take all options from selected style", ->
      element = $("""<div></div>""").get(0)
      opentip = new Opentip element, style: "glass", showOn: "click"

      # Should have been set by the options
      expect(opentip.options.showOn).to.equal "click"
      # Should have been set by the glass theme
      expect(opentip.options.className).to.equal "glass"
      # Should have been set by the standard theme
      expect(opentip.options.stemSize).to.equal 8

    it "should set the options to fixed if a target is provided", ->
      element = $("""<div></div>""").get(0)
      opentip = new Opentip element, target: yes, fixed: no
      expect(opentip.options.fixed).to.be.ok()



  describe "setContent()", ->
    it "should update the content if tooltip currently visible", ->
      opentip = new Opentip "div", "content"
      stub = sinon.stub opentip, "updateElementContent"
      opentip.visible = no
      opentip.setContent "TEST"
      opentip.visible = yes
      opentip.setContent "TEST2"
      expect(stub.callCount).to.equal 1

