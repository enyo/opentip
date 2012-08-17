
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
    describe "arguments", ->
      it "should be optional", ->
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

      it "should use the href attribute if ajax and an A element", ->
        opentip = new Opentip ""

  describe "setContent()", ->
    it "should update the content if tooltip currently visible", ->
      opentip = new Opentip "div", "content"
      stub = sinon.stub opentip, "updateElementContent"
      opentip.visible = no
      opentip.setContent "TEST"
      opentip.visible = yes
      opentip.setContent "TEST2"
      expect(stub.callCount).to.equal 1

