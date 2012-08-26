
$ = ender

describe "Opentip - AJAX", ->
  adapter = Opentip.adapters.native
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    Opentip.adapter = adapter
    triggerElementExists = yes

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip.deactivate()
    $(".opentip-container").remove()

  describe "_loadAjax()", ->
    it "should use adapter.ajax"