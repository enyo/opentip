
$ = jQuery

describe "Opentip - AJAX", ->
  adapter = Opentip.adapter
  opentip = null
  triggerElementExists = yes

  beforeEach ->
    triggerElementExists = yes

  afterEach ->
    opentip[prop]?.restore?() for own prop of opentip
    opentip.deactivate()
    $(".opentip-container").remove()

  describe "_loadAjax()", ->
    describe "on success", ->
      beforeEach ->
        sinon.stub adapter, "ajax", (options) ->
          options.onSuccess "response text"
          options.onComplete()
      afterEach ->
        adapter.ajax.restore()
      it "should use adapter.ajax", ->
        opentip = new Opentip adapter.create("<div></div>"), "Test", ajax: "http://www.test.com", ajaxMethod: "post"
        opentip._loadAjax()
        expect(adapter.ajax.callCount).to.be 1
        expect(adapter.ajax.args[0][0].url).to.equal "http://www.test.com"
        expect(adapter.ajax.args[0][0].method).to.equal "post"
      it "should be called by show() and update the content (only once!)", ->
        opentip = new Opentip adapter.create("<div></div>"), "Test", ajax: "http://www.test.com", ajaxMethod: "post", ajaxCache: yes
        sinon.stub opentip, "_triggerElementExists", -> yes

        sinon.stub opentip, "setContent", (content) -> expect(content).to.be "response text"

        opentip.show()
        opentip.hide()
        opentip.show()
        opentip.hide()
        opentip.show()
        opentip.hide()
        expect(adapter.ajax.callCount).to.be 1
        expect(opentip.setContent.callCount).to.be 1

      it "if ajaxCache: false, should be called by show() and update the content every time show is called", ->
        opentip = new Opentip adapter.create("<div></div>"), "Test", ajax: "http://www.test.com", ajaxMethod: "post", ajaxCache: no
        sinon.stub opentip, "_triggerElementExists", -> yes
        sinon.stub opentip, "setContent", (content) ->
          expect(content).to.be "response text"
        opentip.show()
        opentip.hide()
        opentip.show()
        opentip.hide()
        opentip.show()
        opentip.hide()
        expect(adapter.ajax.callCount).to.be 3
        expect(opentip.setContent.callCount).to.be 3

    describe "on error", ->
      beforeEach ->
        sinon.stub adapter, "ajax", (options) ->
          options.onError "Some error"
      afterEach ->
        adapter.ajax.restore()

      it "should use the options.ajaxErrorMessage on failure", ->
        opentip = new Opentip adapter.create("<div></div>"), "Test", ajax: "http://www.test.com", ajaxMethod: "post", ajaxErrorMessage: "No download dude."

        expect(opentip.options.ajaxErrorMessage).to.be "No download dude."

        expect(opentip.content).to.be "Test"

        opentip._loadAjax()

        expect(opentip.content).to.be opentip.options.ajaxErrorMessage