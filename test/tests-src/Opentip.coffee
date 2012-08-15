
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


  describe "setContent()", ->
    it "should update the content if tooltip currently visible"