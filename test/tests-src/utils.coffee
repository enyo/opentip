
describe "utils", ->

  describe "debug()", ->
    consoleDebug = console.debug
    beforeEach -> sinon.stub console, "debug"
    afterEach -> console.debug.restore()

    it "should only debug when Opentip.debug == true", ->
      Opentip.debug = off
      Opentip::debug "test"
      expect(console.debug.called).to.not.be.ok()
      Opentip.debug = on
      Opentip::debug "test"
      expect(console.debug.called).to.be.ok()

    it "should include the opentip id", ->
      Opentip.debug = on
      opentip = new Opentip document.createElement("span")
      # Automatically calls debug but to make sure:
      opentip.debug "test"
      expect(console.debug.getCall(0).args[0]).to.be "##{opentip.id} |"

  describe "sanitizePosition()", ->
    it "should properly camelize positions", ->
      expect(Opentip::sanitizePosition "top-left").to.equal "topLeft"
      expect(Opentip::sanitizePosition "top-Right").to.equal "topRight"
      expect(Opentip::sanitizePosition "BOTTOM left").to.equal "bottomLeft"
    it "should handle any order of positions", ->
      expect(Opentip::sanitizePosition "right bottom").to.equal "bottomRight"
      expect(Opentip::sanitizePosition "left left middle").to.equal "left"
      expect(Opentip::sanitizePosition "left - top").to.equal "topLeft"

  describe "ucfirst()", ->
    it "should transform the first character to uppercase", ->
      expect(Opentip::ucfirst "abc def").to.equal "Abc def"

  describe "dasherize()", ->
    it "should transform camelized words into dasherized", ->
      expect(Opentip::dasherize "testAbcHoiTEST").to.equal "test-abc-hoi-t-e-s-t"

  describe "setCss3Style()", ->
    Opentip.adapter = adapter = Opentip.adapters.native
    opentip = new Opentip adapter.create("<div></div>"), "Test"
    it "should set the style for all vendors", ->
      element = document.createElement "div"
      opentip.setCss3Style element, { opacity: "0.5", "transition-duration": "1s" }
      expect(element.style["-moz-transition-duration"]).to.be "1s"
      expect(element.style["-moz-opacity"]).to.be "0.5"
      expect(element.style["-webkit-transition-duration"]).to.be "1s"
      expect(element.style["-o-transition-duration"]).to.be "1s"
