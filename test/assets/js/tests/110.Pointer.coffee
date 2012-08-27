
describe "Opentip.Pointer", ->

  describe "constructor()", ->
    it "should forward to set()", ->
      sinon.stub Opentip.Pointer::, "set"
      new Opentip.Pointer "abc"
      expect(Opentip.Pointer::set.args[0][0]).to.be "abc"
      Opentip.Pointer::set.restore()
    it "should accept Pointer objects", ->
      p = new Opentip.Pointer "top left"
      expect(p.toString()).to.be "top left"
      p2 = new Opentip.Pointer p
      expect(p).to.not.be p2
      expect(p2.toString()).to.be "top left"

  describe "set()", ->
    it "should properly set the positions", ->
      p = new Opentip.Pointer
      p.set "top-left"
      expect(p.toString()).to.eql "top left"
      
      p.set "top-Right"
      expect(p.toString()).to.eql "top right"

      p.set "BOTTOM left"
      expect(p.toString()).to.eql "bottom left"

    it "should handle any order of positions", ->
      p = new Opentip.Pointer
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
        thisPositions = Opentip.adapters.native.extend { }, positions, thisPositions
        for positionName, shouldBeTrue of thisPositions
          testCount()
          console.log position, positionName, shouldBeTrue
          if shouldBeTrue then expect(position[positionName]).to.be.ok()
          else expect(position[positionName]).to.not.be.ok()

      testPointers (new Opentip.Pointer("top")), center: yes, top: yes
      testPointers (new Opentip.Pointer("top right")), right: yes, top: yes
      testPointers (new Opentip.Pointer("right")), right: yes, middle: yes
      testPointers (new Opentip.Pointer("bottom right")), right: yes, bottom: yes
      testPointers (new Opentip.Pointer("bottom")), center: yes, bottom: yes
      testPointers (new Opentip.Pointer("bottom left")), left: yes, bottom: yes
      testPointers (new Opentip.Pointer("left")), left: yes, middle: yes
      testPointers (new Opentip.Pointer("top left")), left: yes, top: yes

      # Just making sure that the tests are actually called
      expect(testCount.callCount).to.be 6 * 8

  describe "setHorizontal()", ->
    it "should set the horizontal position", ->
      p = new Opentip.Pointer "top left"
      expect(p.left).to.be.ok();
      expect(p.top).to.be.ok();
      p.setHorizontal "right"
      expect(p.left).to.not.be.ok();
      expect(p.top).to.be.ok();
      expect(p.right).to.be.ok();

  describe "setVertical()", ->
    it "should set the vertical position", ->
      p = new Opentip.Pointer "top left"
      expect(p.top).to.be.ok();
      expect(p.left).to.be.ok();
      p.setVertical "bottom"
      expect(p.top).to.not.be.ok();
      expect(p.left).to.be.ok();
      expect(p.bottom).to.be.ok();

  describe "flip()", ->
    it "should return itself for chaining", ->
      p = new Opentip.Pointer "top"
      p2 = p.flip()
      expect(p).to.be p2
    it "should properly flip the position", ->
      expect(new Opentip.Pointer("top").flip().toString()).to.be "bottom"
      expect(new Opentip.Pointer("bottomRight").flip().toString()).to.be "top left"
      expect(new Opentip.Pointer("left top").flip().toString()).to.be "bottom right"
      expect(new Opentip.Pointer("bottom").flip().toString()).to.be "top"

