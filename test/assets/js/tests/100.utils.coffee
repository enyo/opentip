
describe "utils", ->
  adapter = Opentip.adapter

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

  describe "ucfirst()", ->
    it "should transform the first character to uppercase", ->
      expect(Opentip::ucfirst "abc def").to.equal "Abc def"

  describe "dasherize()", ->
    it "should transform camelized words into dasherized", ->
      expect(Opentip::dasherize "testAbcHoiTEST").to.equal "test-abc-hoi-t-e-s-t"

  describe "_positionsEqual()", ->
    it "should properly compare positions", ->
      eq = Opentip::_positionsEqual
      expect(eq { left: 0, top: 0 }, { left: 0, top: 0 }).to.be.ok()
      expect(eq { left: 100, top: 20 }, { left: 100, top: 20 }).to.be.ok()
      expect(eq { left: 100, top: 20 }, { left: 101, top: 20 }).to.not.be.ok()
      expect(eq null, { left: 101, top: 20 }).to.not.be.ok()
      expect(eq null, null).to.not.be.ok()

  describe "_dimensionsEqual()", ->
    it "should properly compare dimensions", ->
      eq = Opentip::_dimensionsEqual
      expect(eq { width: 0, height: 0 }, { width: 0, height: 0 }).to.be.ok()
      expect(eq { width: 100, height: 20 }, { width: 100, height: 20 }).to.be.ok()
      expect(eq { width: 100, height: 20 }, { width: 101, height: 20 }).to.not.be.ok()
      expect(eq null, { width: 101, height: 20 }).to.not.be.ok()
      expect(eq null, null).to.not.be.ok()

  describe "setCss3Style()", ->
    opentip = new Opentip adapter.create("<div></div>"), "Test"
    it "should set the style for all vendors", ->
      element = document.createElement "div"
      opentip.setCss3Style element, { opacity: "0.5", transitionDuration: "1s" }
      transitionDuration = false
      opacity = false

      for vendor in [
        ""
        "Khtml"
        "Ms"
        "O"
        "Moz"
        "Webkit"
      ]
        prop = if vendor then "#{vendor}TransitionDuration" else "transitionDuration"
        transitionDuration = true if element.style[prop] == "1s"
        prop = if vendor then "#{vendor}Opacity" else "opacity"
        opacity = true if element.style[prop] == "0.5"
      # expect(element.style["-moz-transition-duration"]).to.be "1s"
      # expect(element.style["-moz-opacity"]).to.be "0.5"
      expect(transitionDuration).to.be true
      expect(opacity).to.be true
      # expect(element.style["-o-transition-duration"]).to.be "1s"

  describe "defer()", ->
    it "should call the callback as soon as possible"

  describe "setTimeout()", ->
    it "should wrap window.setTimeout but with seconds"

