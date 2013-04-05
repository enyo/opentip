

extend = (target, sources...) ->
  for source in sources
    for own key, val of source
      target[key] = val
  target

describe "Opentip.Joint", ->

  describe "constructor()", ->
    it "should forward to set()", ->
      sinon.stub Opentip.Joint::, "set"
      new Opentip.Joint "abc"
      expect(Opentip.Joint::set.args[0][0]).to.be "abc"
      Opentip.Joint::set.restore()
    it "should accept Pointer objects", ->
      p = new Opentip.Joint "top left"
      expect(p.toString()).to.be "top left"
      p2 = new Opentip.Joint p
      expect(p).to.not.be p2
      expect(p2.toString()).to.be "top left"

  describe "set()", ->
    it "should properly set the positions", ->
      p = new Opentip.Joint
      p.set "top-left"
      expect(p.toString()).to.eql "top left"
      
      p.set "top-Right"
      expect(p.toString()).to.eql "top right"

      p.set "BOTTOM left"
      expect(p.toString()).to.eql "bottom left"

    it "should handle any order of positions", ->
      p = new Opentip.Joint
      p.set "right bottom"
      expect(p.toString()).to.eql "bottom right"

      p.set "left left middle"
      expect(p.toString()).to.eql "left"

      p.set "left - top"
      expect(p.toString()).to.eql "top left"

    it "should add .bottom, .left etc... properties on the position", ->
      positions = 
        top: no
        bottom: no
        middle: no
        left: no
        center: no
        right: no

      testCount = sinon.stub()
      testPointers = (position, thisPositions) ->
        thisPositions = extend { }, positions, thisPositions
        for positionName, shouldBeTrue of thisPositions
          testCount()
          if shouldBeTrue then expect(position[positionName]).to.be.ok()
          else expect(position[positionName]).to.not.be.ok()

      testPointers (new Opentip.Joint("top")), center: yes, top: yes
      testPointers (new Opentip.Joint("top right")), right: yes, top: yes
      testPointers (new Opentip.Joint("right")), right: yes, middle: yes
      testPointers (new Opentip.Joint("bottom right")), right: yes, bottom: yes
      testPointers (new Opentip.Joint("bottom")), center: yes, bottom: yes
      testPointers (new Opentip.Joint("bottom left")), left: yes, bottom: yes
      testPointers (new Opentip.Joint("left")), left: yes, middle: yes
      testPointers (new Opentip.Joint("top left")), left: yes, top: yes

      # Just making sure that the tests are actually called
      expect(testCount.callCount).to.be 6 * 8

  describe "setHorizontal()", ->
    it "should set the horizontal position", ->
      p = new Opentip.Joint "top left"
      expect(p.left).to.be.ok();
      expect(p.top).to.be.ok();
      p.setHorizontal "right"
      expect(p.left).to.not.be.ok();
      expect(p.top).to.be.ok();
      expect(p.right).to.be.ok();

  describe "setVertical()", ->
    it "should set the vertical position", ->
      p = new Opentip.Joint "top left"
      expect(p.top).to.be.ok();
      expect(p.left).to.be.ok();
      p.setVertical "bottom"
      expect(p.top).to.not.be.ok();
      expect(p.left).to.be.ok();
      expect(p.bottom).to.be.ok();

  describe "flip()", ->
    it "should return itself for chaining", ->
      p = new Opentip.Joint "top"
      p2 = p.flip()
      expect(p).to.be p2
    it "should properly flip the position", ->
      expect(new Opentip.Joint("top").flip().toString()).to.be "bottom"
      expect(new Opentip.Joint("bottomRight").flip().toString()).to.be "top left"
      expect(new Opentip.Joint("left top").flip().toString()).to.be "bottom right"
      expect(new Opentip.Joint("bottom").flip().toString()).to.be "top"

