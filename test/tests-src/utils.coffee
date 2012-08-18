
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
