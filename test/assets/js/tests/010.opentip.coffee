
$ = jQuery

describe "Opentip", ->
  adapter = null
  beforeEach ->
    adapter = Opentip.adapter

  afterEach ->
    elements = $(".opentip-container")
    elements.remove()


  describe "constructor()", ->
    before ->
      sinon.stub Opentip::, "_setup"
    after ->
      Opentip::_setup.restore()
    it "arguments should be optional", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, "content"
      expect(opentip.content).to.equal "content"
      expect(adapter.unwrap(opentip.triggerElement)).to.equal adapter.unwrap element

      opentip = new Opentip element, "content", "title", { hideOn: "click" }
      expect(opentip.content).to.equal "content"
      expect(adapter.unwrap opentip.triggerElement).to.equal adapter.unwrap element
      expect(opentip.options.hideOn).to.equal "click"
      expect(opentip.options.title).to.equal "title"

      opentip = new Opentip element, { hideOn: "click" }
      expect(adapter.unwrap opentip.triggerElement).to.equal adapter.unwrap element
      expect(opentip.options.hideOn).to.equal "click"
      expect(opentip.content).to.equal ""
      expect(opentip.options.title).to.equal undefined

    it "should always use the next tip id", ->
      element = document.createElement "div"
      Opentip.lastId = 0
      opentip = new Opentip element, "Test"
      opentip2 = new Opentip element, "Test"
      opentip3 = new Opentip element, "Test"
      expect(opentip.id).to.be 1
      expect(opentip2.id).to.be 2
      expect(opentip3.id).to.be 3

    it "should use the href attribute if AJAX and an A element", ->
      element = $("""<a href="http://testlink">link</a>""")[0]
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.equal "http://testlink"

    it "should disable AJAX if neither URL or a link HREF is provided", ->
      element = $("""<div>text</div>""")[0]
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.be false

    it "should disable a link if the event is onClick", ->
      sinon.stub adapter, "observe"
      element = $("""<a href="http://testlink">link</a>""")[0]
      sinon.stub Opentip::, "_setupObservers"
      opentip = new Opentip element, showOn: "click"


      expect(adapter.observe.calledOnce).to.be.ok()
      expect(adapter.observe.getCall(0).args[1]).to.equal "click"


      Opentip::_setupObservers.restore()
      adapter.observe.restore()

    it "should take all options from selected style", ->
      element = document.createElement "div"
      opentip = new Opentip element, style: "glass", showOn: "click"

      # Should have been set by the options
      expect(opentip.options.showOn).to.equal "click"
      # Should have been set by the glass theme
      expect(opentip.options.className).to.equal "glass"
      # Should have been set by the standard theme
      expect(opentip.options.stemLength).to.equal 5

    it "the property 'style' should be handled the same as 'extends'", ->
      element = document.createElement "div"
      opentip = new Opentip element, extends: "glass", showOn: "click"

      # Should have been set by the options
      expect(opentip.options.showOn).to.equal "click"
      # Should have been set by the glass theme
      expect(opentip.options.className).to.equal "glass"
      # Should have been set by the standard theme
      expect(opentip.options.stemLength).to.equal 5

    it "chaining incorrect styles should throw an exception", ->
      element = document.createElement "div"
      expect(-> new Opentip element, { extends: "invalidstyle" }).to.throwException /Invalid style\: invalidstyle/

    it "chaining styles should work", ->
      element = document.createElement "div"

      Opentip.styles.test1 = stemLength: 40
      Opentip.styles.test2 = extends: "test1", title: "overwritten title"
      Opentip.styles.test3 = extends: "test2", className: "test5", title: "some title"

      opentip = new Opentip element, { extends: "test3", stemBase: 20 }

      expect(opentip.options.className).to.equal "test5"
      expect(opentip.options.title).to.equal "some title"
      expect(opentip.options.stemLength).to.equal 40
      expect(opentip.options.stemBase).to.equal 20

    it "should set the options to fixed if a target is provided", ->
      element = document.createElement "div"
      opentip = new Opentip element, target: yes, fixed: no
      expect(opentip.options.fixed).to.be.ok()

    it "should use provided stem", ->
      element = document.createElement "div"
      opentip = new Opentip element, stem: "bottom", tipJoin: "topLeft"
      expect(opentip.options.stem.toString()).to.eql "bottom"

    it "should take the tipJoint as stem if stem is just true", ->
      element = document.createElement "div"
      opentip = new Opentip element, stem: yes, tipJoint: "top left"
      expect(opentip.options.stem.toString()).to.eql "top left"

    it "should use provided target", ->
      element = adapter.create "<div></div>"
      element2 = adapter.create "<div></div>"
      opentip = new Opentip element, target: element2
      expect(adapter.unwrap opentip.options.target).to.equal adapter.unwrap element2

    it "should take the triggerElement as target if target is just true", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, target: yes
      expect(adapter.unwrap opentip.options.target).to.equal adapter.unwrap element

    it "currentStemPosition should be set to inital stemPosition", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, stem: "topLeft"
      expect(opentip.currentStem.toString()).to.eql "top left"

    it "delay should be automatically set if none provided", ->
      element = document.createElement "div"
      opentip = new Opentip element, delay: null, showOn: "click"
      expect(opentip.options.delay).to.equal 0
      opentip = new Opentip element, delay: null, showOn: "mouseover"
      expect(opentip.options.delay).to.equal 0.2

    it "the targetJoint should be the inverse of the tipJoint if none provided", ->
      element = document.createElement "div"
      opentip = new Opentip element, tipJoint: "left"
      expect(opentip.options.targetJoint.toString()).to.eql "right"
      opentip = new Opentip element, tipJoint: "top"
      expect(opentip.options.targetJoint.toString()).to.eql "bottom"
      opentip = new Opentip element, tipJoint: "bottom right"
      expect(opentip.options.targetJoint.toString()).to.eql "top left"


    it "should setup all trigger elements", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, showOn: "click"
      expect(opentip.showTriggers[0].event).to.eql "click"
      expect(adapter.unwrap opentip.showTriggers[0].element).to.equal adapter.unwrap element
      expect(opentip.showTriggersWhenVisible).to.eql [ ]
      expect(opentip.hideTriggers).to.eql [ ]
      opentip = new Opentip element, showOn: "creation"
      expect(opentip.showTriggers).to.eql [ ]
      expect(opentip.showTriggersWhenVisible).to.eql [ ]
      expect(opentip.hideTriggers).to.eql [ ]

    it "should copy options.hideTrigger onto options.hideTriggers", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, hideTrigger: "closeButton", hideTriggers: [ ]
      expect(opentip.options.hideTriggers).to.eql [ "closeButton"]

    it "should NOT copy options.hideTrigger onto options.hideTriggers when hideTriggers are set", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, hideTrigger: "closeButton", hideTriggers: [ "tip", "trigger" ]
      expect(opentip.options.hideTriggers).to.eql [ "tip", "trigger" ]

    it "should attach itself to the elements `data-opentips` property", ->
      element = $("<div></div>")[0]
      expect(adapter.data element, "opentips").to.not.be.ok()
      opentip = new Opentip element
      expect(adapter.data element, "opentips").to.eql [ opentip ]
      opentip2 = new Opentip element
      opentip3 = new Opentip element
      expect(adapter.data element, "opentips").to.eql [ opentip, opentip2, opentip3 ]

    it "should add itself to the Opentip.tips list", ->
      element = $("<div></div>")[0]
      Opentip.tips = [ ]
      opentip1 = new Opentip element
      opentip2 = new Opentip element
      expect(Opentip.tips.length).to.equal 2
      expect(Opentip.tips[0]).to.equal opentip1
      expect(Opentip.tips[1]).to.equal opentip2

    it "should rename ajaxCache to cache for backwards compatibility", ->
      element = $("<div></div>")[0]
      opentip1 = new Opentip element, ajaxCache: off
      opentip2 = new Opentip element, ajaxCache: on

      expect(opentip1.options.ajaxCache == opentip2.options.ajaxCache == undefined).to.be.ok()
      expect(opentip1.options.cache).to.not.be.ok()
      expect(opentip2.options.cache).to.be.ok()

  describe "init()", ->
    describe "showOn == creation", ->
      element = document.createElement "div"
      beforeEach -> sinon.stub Opentip::, "prepareToShow"
      afterEach -> Opentip::prepareToShow.restore()
      it "should immediately call prepareToShow()", ->
        opentip = new Opentip element, showOn: "creation"
        expect(opentip.prepareToShow.callCount).to.equal 1

  describe "setContent()", ->
    it "should update the content if tooltip currently visible", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip, "_updateElementContent"
      opentip.visible = no
      opentip.setContent "TEST"
      expect(opentip.content).to.equal "TEST"
      opentip.visible = yes
      opentip.setContent "TEST2"
      expect(opentip.content).to.equal "TEST2"
      expect(opentip._updateElementContent.callCount).to.equal 1
      opentip._updateElementContent.restore()
      
    it "should not set the content directly if function", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip, "_updateElementContent"
      opentip.setContent -> "TEST"
      expect(opentip.content).to.equal ""


  describe "_updateElementContent()", ->

    it "should escape the content if @options.escapeContent", ->
      element = document.createElement "div"
      opentip = new Opentip element, "<div><span></span></div>", escapeContent: yes
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect($(opentip.container).find(".ot-content").html()).to.be """&lt;div&gt;&lt;span&gt;&lt;/span&gt;&lt;/div&gt;"""
      
    it "should not escape the content if not @options.escapeContent", ->
      element = document.createElement "div"
      opentip = new Opentip element, "<div><span></span></div>", escapeContent: no
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect($(opentip.container).find(".ot-content > div > span").length).to.be 1

    it "should storeAndLock dimensions and reposition the element", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip, "_storeAndLockDimensions"
      sinon.stub opentip, "reposition"
      opentip.visible = yes
      opentip._updateElementContent()
      expect(opentip._storeAndLockDimensions.callCount).to.equal 1
      expect(opentip.reposition.callCount).to.equal 1

    it "should execute the content function", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip.adapter, "find", -> "element"
      opentip.visible = yes
      opentip.setContent -> "BLA TEST"
      expect(opentip.content).to.be "BLA TEST"
      opentip.adapter.find.restore()

    it "should only execute the content function once if cache:true", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click", cache: yes
      sinon.stub opentip.adapter, "find", -> "element"
      opentip.visible = yes
      counter = 0
      opentip.setContent -> "count#{counter++}"
      expect(opentip.content).to.be "count0"
      opentip._updateElementContent()
      opentip._updateElementContent()
      expect(opentip.content).to.be "count0"
      opentip.adapter.find.restore()

    it "should execute the content function multiple times if cache:false", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click", cache: no
      sinon.stub opentip.adapter, "find", -> "element"
      opentip.visible = yes
      counter = 0
      opentip.setContent -> "count#{counter++}"
      expect(opentip.content).to.be "count0"
      opentip._updateElementContent()
      opentip._updateElementContent()
      expect(opentip.content).to.be "count2"
      opentip.adapter.find.restore()

    it "should only update the HTML elements if the content has been changed", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip.adapter, "find", -> "element"
      sinon.stub opentip.adapter, "update", ->
      opentip.visible = yes

      opentip.setContent "TEST"
      expect(opentip.adapter.update.callCount).to.be 1
      opentip._updateElementContent()
      opentip._updateElementContent()
      expect(opentip.adapter.update.callCount).to.be 1
      opentip.setContent "TEST2"
      expect(opentip.adapter.update.callCount).to.be 2
      opentip.adapter.find.restore()
      opentip.adapter.update.restore()


  describe "_buildContainer()", ->
    element = document.createElement "div"
    opentip = null
    beforeEach ->
      opentip = new Opentip element,
        style: "glass"
        showEffect: "appear"
        hideEffect: "fade"
      opentip._setup()

    it "should set the id", ->
      expect(adapter.attr opentip.container, "id").to.equal "opentip-" + opentip.id
    it "should set the classes", ->
      enderElement = $ adapter.unwrap opentip.container
      expect(enderElement.hasClass "opentip-container").to.be.ok()
      expect(enderElement.hasClass "ot-hidden").to.be.ok()
      expect(enderElement.hasClass "style-glass").to.be.ok()
      expect(enderElement.hasClass "ot-show-effect-appear").to.be.ok()
      expect(enderElement.hasClass "ot-hide-effect-fade").to.be.ok()

  describe "_buildElements()", ->
    element = opentip = null

    beforeEach ->
      element = document.createElement "div"
      opentip = new Opentip element, "the content", "the title", hideTrigger: "closeButton", stem: "top left", ajax: "bla"
      opentip._setup()
      opentip._buildElements()

    it "should add a h1 if title is provided", ->
      enderElement = $ adapter.unwrap opentip.container
      headerElement = enderElement.find "> .opentip > .ot-header > h1"
      expect(headerElement.length).to.be.ok()
      expect(headerElement.html()).to.be "the title"

    it "should add a loading indicator if ajax", ->
      enderElement = $ adapter.unwrap opentip.container
      loadingElement = enderElement.find "> .opentip > .ot-loading-indicator > span"
      expect(loadingElement.length).to.be.ok()
      expect(loadingElement.html()).to.be "↻"

    it "should add a close button if hideTrigger = close", ->
      enderElement = $ adapter.unwrap opentip.container
      closeButton = enderElement.find "> .opentip > .ot-header > a.ot-close > span"
      expect(closeButton.length).to.be.ok()
      expect(closeButton.html()).to.be "Close"

  describe "addAdapter()", ->
    it "should set the current adapter, and add the adapter to the list", ->
      expect(Opentip.adapters.testa).to.not.be.ok()
      testAdapter = { name: "testa" }
      Opentip.addAdapter testAdapter
      expect(Opentip.adapters.testa).to.equal testAdapter

    it "should use adapter.domReady to call findElements() with it"

  describe "_setupObservers()", ->
    it "should never setup the same observers twice"

  describe "_searchAndActivateCloseButtons()", ->
    it "should do what it says"

  describe "_activateFirstInput()", ->
    it "should do what it says", ->
      element = document.createElement "div"
      opentip = new Opentip element, "<input /><textarea>", escapeContent: false
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()

      input = $("input", opentip.container)[0]
      expect(document.activeElement).to.not.be input
      opentip._activateFirstInput()
      input.focus()
      expect(document.activeElement).to.be input



