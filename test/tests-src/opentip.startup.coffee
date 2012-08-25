
$ = ender

describe "Opentip - Startup", ->
  adapter = Opentip.adapters.native
  opentip = null

  beforeEach ->
    Opentip.adapter = adapter

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip?.deactivate?()
    $("[data-ot]").remove()
    $(".opentip-container").remove()

  it "should find all elements with data-ot()", ->
    $ """<div data-ot="Content text"></div>"""
    Opentip.findElements()
