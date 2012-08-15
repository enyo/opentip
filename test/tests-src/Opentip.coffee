
describe "Opentip", ->
  describe "debug()", ->
    consoleDebug = console.debug
    beforeEach -> sinon.stub console, "debug"
    afterEach -> console.debug.restore()

    it "should only debug when debugging == true", ->
      Opentip.debugging = off
      Opentip.debug "test"
      expect(console.debug.called).to.be.false
      Opentip.debugging = on
      Opentip.debug "test"
      expect(console.debug.called).to.be.true

  describe "sanitizePosition()", ->
    it "should properly parse all 8 possible positions", ->
      expect(Opentip.sanitizePosition [ "center", "top" ]).to.equal Opentip.position.top
      expect(Opentip.sanitizePosition [ "right", "top" ]).to.equal Opentip.position.topRight
      expect(Opentip.sanitizePosition [ "right", "middle" ]).to.equal Opentip.position.right
      expect(Opentip.sanitizePosition [ "right", "bottom" ]).to.equal Opentip.position.bottomRight
      expect(Opentip.sanitizePosition [ "center", "bottom" ]).to.equal Opentip.position.bottom
      expect(Opentip.sanitizePosition [ "left", "bottom" ]).to.equal Opentip.position.bottomLeft
      expect(Opentip.sanitizePosition [ "left", "middle" ]).to.equal Opentip.position.left
      expect(Opentip.sanitizePosition [ "left", "top" ]).to.equal Opentip.position.topLeft

  describe "ucfirst()", ->
    it "should transform the first character to uppercase", ->
      expect(Opentip.ucfirst "abc def").to.equal "Abc def"
