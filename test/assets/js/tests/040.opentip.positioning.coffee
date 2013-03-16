
$ = jQuery

describe "Opentip - Positioning", ->
  adapter = Opentip.adapter
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    triggerElementExists = yes

  afterEach ->
    opentip[prop]?.restore?() for prop of opentip
    $(".opentip-container").remove()

  describe "fixed", ->
    element = adapter.create("""<div style="display: block; position: absolute; top: 500px; left: 500px; width: 50px; height: 50px;"></div>""")
    beforeEach ->
      adapter.append document.body, element
    afterEach ->
      $(adapter.unwrap element).remove()

    describe "without autoOffset", ->
      it "should correctly position opentip without border and stem", ->
        opentip = new Opentip element, "Test", delay: 0, target: yes, borderWidth: 0, stem: off, offset: [ 0, 0 ], autoOffset: false
        opentip._setup()
        elementOffset = adapter.offset element
        expect(elementOffset).to.eql left: 500, top: 500
        opentip.reposition()
        expect(opentip.currentPosition).to.eql left: 550, top: 550
      it "should correctly position opentip with", ->
        opentip = new Opentip element, "Test", delay: 0, target: yes, borderWidth: 10, stem: off, offset: [ 0, 0 ], autoOffset: false
        opentip._setup()
        elementOffset = adapter.offset element
        opentip.reposition()
        expect(opentip.currentPosition).to.eql left: 560, top: 560
      it "should correctly position opentip with stem on the left", ->
        opentip = new Opentip element, "Test", delay: 0, target: yes, borderWidth: 0, stem: yes, tipJoint: "top left", stemLength: 5, offset: [ 0, 0 ], autoOffset: false
        opentip._setup()
        elementOffset = adapter.offset element
        opentip.reposition()
        expect(opentip.currentPosition).to.eql left: 550, top: 550
      it "should correctly position opentip on the bottom right", ->
        opentip = new Opentip element, "Test", delay: 0, target: yes, borderWidth: 0, stem: off, tipJoint: "bottom right", offset: [ 0, 0 ], autoOffset: false
        opentip._setup()
        opentip.dimensions = width: 200, height: 200
        elementOffset = adapter.offset element
        elementDimensions = adapter.dimensions element
        expect(elementDimensions).to.eql width: 50, height: 50
        opentip.reposition()
        expect(opentip.currentPosition).to.eql left: 300, top: 300
      it "should correctly position opentip on the bottom right with stem", ->
        opentip = new Opentip element, "Test", delay: 0, target: yes, borderWidth: 0, stem: yes, tipJoint: "bottom right", stemLength: 10, offset: [ 0, 0 ], autoOffset: false
        opentip._setup()
        opentip.dimensions = width: 200, height: 200
        elementOffset = adapter.offset element
        elementDimensions = adapter.dimensions element
        expect(elementDimensions).to.eql width: 50, height: 50
        opentip.reposition()
        expect(opentip.currentPosition).to.eql left: 300, top: 300 # The autoOffset takes care of accounting for the stem


  describe "following mouse", ->
    it "should correctly position opentip when following mouse"

  describe "_ensureViewportContainment()", ->
    it "should put the tooltip on the other side when it's sticking out"
    it "shouldn't do anything if the viewport is smaller than the tooltip"
    it "should revert if the tooltip sticks out the other side as well"

