
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
      expect(Opentip::sanitizePosition("top-left").toString()).to.eql "topLeft"
      expect(Opentip::sanitizePosition("top-Right").toString()).to.eql "topRight"
      expect(Opentip::sanitizePosition("BOTTOM left").toString()).to.eql "bottomLeft"
    it "should handle any order of positions", ->
      expect(Opentip::sanitizePosition("right bottom").toString()).to.eql "bottomRight"
      expect(Opentip::sanitizePosition("left left middle").toString()).to.eql "left"
      expect(Opentip::sanitizePosition("left - top").toString()).to.eql "topLeft"
    it "should throw an exception if unknonwn position", ->
      try
        Opentip::sanitizePosition "center middle"
        expect(false).to.be.ok()
      catch e
      try
        Opentip::sanitizePosition ""
        expect(false).to.be.ok()
      catch e

    it "should add .bottom, .left etc... properties on the position", ->
      positions = 
        top: no
        bottom: no
        middle: no
        left: no
        center: no
        right: no

      testCount = sinon.stub()
      testPositions = (position, thisPositions) ->
        thisPositions = Opentip.adapters.native.extend { }, positions, thisPositions
        for positionName, shouldBeTrue of thisPositions
          testCount()
          if shouldBeTrue then expect(position[positionName]).to.be.ok()
          else expect(position[positionName]).to.not.be.ok()

      testPositions Opentip::sanitizePosition("top"), center: yes, top: yes
      testPositions Opentip::sanitizePosition("top right"), right: yes, top: yes
      testPositions Opentip::sanitizePosition("right"), right: yes, middle: yes
      testPositions Opentip::sanitizePosition("bottom right"), right: yes, bottom: yes
      testPositions Opentip::sanitizePosition("bottom"), center: yes, bottom: yes
      testPositions Opentip::sanitizePosition("bottom left"), left: yes, bottom: yes
      testPositions Opentip::sanitizePosition("left"), left: yes, middle: yes
      testPositions Opentip::sanitizePosition("top left"), left: yes, top: yes

      # Just making sure that the tests are actually called
      expect(testCount.callCount).to.be 6 * 8

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

  describe "defer()", ->
    it "should call the callback as soon as possible"

  describe "setTimeout()", ->
    it "should wrap window.setTimeout but with seconds"

