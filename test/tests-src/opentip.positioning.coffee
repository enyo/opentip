
$ = ender

describe "Opentip - Positioning", ->
  adapter = Opentip.adapters.native
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    Opentip.adapter = adapter
    triggerElementExists = yes
    opentip = new Opentip adapter.create("<div></div>"), "Test", delay: 0
    sinon.stub opentip, "_triggerElementExists", -> triggerElementExists

  afterEach ->
    opentip[prop].restore?() for prop of opentip
    $(".opentip-container").remove()

  it "should correctly position opentip when fixed"
  it "should correctly position opentip when following mouse"
