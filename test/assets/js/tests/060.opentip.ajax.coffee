
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
    beforeEach ->
      sinon.stub adapter, "ajax"
    afterEach ->
      adapter.ajax.restore()
    it "should use adapter.ajax", ->
      opentip = new Opentip adapter.create("<div></div>"), "Test", ajax: { url: "http://www.test.com", method: "post" }
      opentip._loadAjax()
      expect(adapter.ajax.callCount).to.be 1
      expect(adapter.ajax.args[0][0].url).to.equal "http://www.test.com"
      expect(adapter.ajax.args[0][0].method).to.equal "post"
    it "should be called by show()"