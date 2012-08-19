
describe "utils", ->

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
