
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
    trigger = $("""<div data-ot="Content text"></div>""").get(0)
    $(document.body).append trigger
    Opentip.findElements()
    expect(adapter.data(trigger, "opentips")).to.be.an Array
    expect(adapter.data(trigger, "opentips").length).to.equal 1
    expect(adapter.data(trigger, "opentips")[0]).to.be.an Opentip

  it "should take configuration from data- attributes", ->
    trigger = $("""<div data-ot="Content text" data-ot-show-on="click" data-ot-hide-trigger="closeButton"></div>""").get(0)
    $(document.body).append trigger
    Opentip.findElements()
    expect(adapter.data(trigger, "opentips")[0]).to.be.an Opentip
    opentip = adapter.data(trigger, "opentips")[0]
    expect(opentip.options.hideTrigger).to.eql "closeButton"
    expect(opentip.options.showOn).to.eql "click"

