
$ = jQuery

describe "Opentip - Startup", ->
  adapter = Opentip.adapter
  opentip = null

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip?.deactivate?()
    $("[data-ot]").remove()
    $(".opentip-container").remove()

  it "should find all elements with data-ot()", ->
    trigger = $("""<div data-ot="Content text"></div>""")[0]
    $(document.body).append trigger
    Opentip.findElements()
    expect(adapter.data(trigger, "opentips")).to.be.an Array
    expect(adapter.data(trigger, "opentips").length).to.equal 1
    expect(adapter.data(trigger, "opentips")[0]).to.be.an Opentip

  it "should take configuration from data- attributes", ->
    trigger = $("""<div data-ot="Content text" data-ot-show-on="click" data-ot-hide-trigger="closeButton"></div>""")[0]
    $(document.body).append trigger
    Opentip.findElements()
    expect(adapter.data(trigger, "opentips")[0]).to.be.an Opentip
    opentip = adapter.data(trigger, "opentips")[0]
    expect(opentip.options.hideTrigger).to.eql "closeButton"
    expect(opentip.options.showOn).to.eql "click"

  it "should properly parse boolean data- attributes", ->
    trigger = $("""<div data-ot="Content text" data-ot-shadow="yes" data-ot-auto-offset="no" data-ot-contain-in-viewport="false"></div>""")[0]
    $(document.body).append trigger
    Opentip.findElements()
    opentip = adapter.data(trigger, "opentips")[0]
    expect(opentip.options.shadow).to.be yes
    expect(opentip.options.autoOffset).to.be no
    expect(opentip.options.containInViewport).to.be no

