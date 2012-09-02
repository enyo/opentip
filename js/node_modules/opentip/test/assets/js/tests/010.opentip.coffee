
$ = ender

describe "Opentip", ->
  adapter = null
  beforeEach ->
    adapter = Opentip.adapters.native
    Opentip.adapter = adapter

  afterEach ->
    $(".opentip-container").remove()

  describe "constructor()", ->
    before ->
      sinon.stub Opentip::, "_init"
    after ->
      Opentip::_init.restore()
    it "arguments should be optional", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, "content"
      expect(opentip.content).to.equal "content"
      expect(adapter.unwrap(opentip.triggerElement)).to.equal adapter.unwrap element

      opentip = new Opentip element, "content", "title", { hideOn: "click" }
      expect(opentip.content).to.equal "content"
      expect(opentip.triggerElement).to.equal element
      expect(opentip.options.hideOn).to.equal "click"
      expect(opentip.options.title).to.equal "title"

      opentip = new Opentip element, { hideOn: "click" }
      expect(opentip.triggerElement).to.equal element
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
      element = $("""<a href="http://testlink">link</a>""").get(0)
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.equal "http://testlink"

    it "should disable AJAX if neither URL or a link HREF is provided", ->
      element = $("""<div>text</div>""").get(0)
      opentip = new Opentip element, ajax: on
      expect(opentip.options.ajax).to.be false

    it "should disable a link if the event is onClick", ->
      sinon.spy adapter, "observe"
      element = $("""<a href="http://testlink">link</a>""").get(0)
      opentip = new Opentip element, showOn: "click"

      expect(adapter.observe.calledOnce).to.be.ok()
      expect(adapter.observe.getCall(0).args[1]).to.equal "click"

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
      expect(opentip.options.target).to.equal element2

    it "should take the triggerElement as target if target is just true", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, target: yes
      expect(opentip.options.target).to.equal element

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
      expect(opentip.showTriggersWhenHidden).to.eql [ { event: "click", element: element } ]
      expect(opentip.showTriggersWhenVisible).to.eql [ ]
      expect(opentip.hideTriggers).to.eql [ ]
      opentip = new Opentip element, showOn: "creation"
      expect(opentip.showTriggersWhenHidden).to.eql [ ]
      expect(opentip.showTriggersWhenVisible).to.eql [ ]
      expect(opentip.hideTriggers).to.eql [ ]

    it "should copy options.hideTrigger onto options.hideTriggers", ->
      element = adapter.create "<div></div>"
      opentip = new Opentip element, hideTrigger: "closeButton", hideTriggers: [ "trigger" ]
      expect(opentip.options.hideTriggers).to.eql [ "trigger", "closeButton"]

    it "should attach itself to the elements `data-opentips` property", ->
      element = $("<div></div>").get(0)
      expect(adapter.data element, "opentips").to.not.be.ok()
      opentip = new Opentip element
      expect(adapter.data element, "opentips").to.eql [ opentip ]
      opentip2 = new Opentip element
      opentip3 = new Opentip element
      expect(adapter.data element, "opentips").to.eql [ opentip, opentip2, opentip3 ]


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
      



  describe "_updateElementContent()", ->
    it "should escape the content if @options.escapeContent", ->
      element = document.createElement "div"
      opentip = new Opentip element, "<div><span></span></div>", escapeContent: yes
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect($(opentip.container).find(".content").html()).to.be """&lt;div&gt;&lt;span&gt;&lt;/span&gt;&lt;/div&gt;"""

    it "should not escape the content if not @options.escapeContent", ->
      element = document.createElement "div"
      opentip = new Opentip element, "<div><span></span></div>", escapeContent: no
      sinon.stub opentip, "_triggerElementExists", -> yes
      opentip.show()
      expect($(opentip.container).find(".content > div > span").length).to.be 1

    it "should storeAndLock dimensions and reposition the element", ->
      element = document.createElement "div"
      opentip = new Opentip element, showOn: "click"
      sinon.stub opentip, "_storeAndLockDimensions"
      sinon.stub opentip, "reposition"
      opentip.visible = yes
      opentip._updateElementContent()
      expect(opentip._storeAndLockDimensions.callCount).to.equal 1
      expect(opentip.reposition.callCount).to.equal 1

  describe "_buildContainer()", ->
    element = document.createElement "div"
    opentip = null
    beforeEach ->
      opentip = new Opentip element,
        style: "glass"
        showEffect: "appear"
        hideEffect: "fade"

    it "should set the id", ->
      expect(adapter.attr opentip.container, "id").to.equal "opentip-" + opentip.id
    it "should set the classes", ->
      enderElement = $ adapter.unwrap opentip.container
      expect(enderElement.hasClass "opentip-container").to.be.ok()
      expect(enderElement.hasClass "hidden").to.be.ok()
      expect(enderElement.hasClass "style-glass").to.be.ok()
      expect(enderElement.hasClass "show-effect-appear").to.be.ok()
      expect(enderElement.hasClass "hide-effect-fade").to.be.ok()

  describe "_buildElements()", ->
    element = opentip = null

    beforeEach ->
      element = document.createElement "div"
      opentip = new Opentip element, "the content", "the title", hideTrigger: "closeButton", stem: "top left", ajax: "bla"
      opentip._buildElements()

    it "should add a h1 if title is provided", ->
      enderElement = $ adapter.unwrap opentip.container
      headerElement = enderElement.find "> .opentip > header > h1"
      expect(headerElement.length).to.be.ok()
      expect(headerElement.html()).to.be "the title"

    it "should add a loading indicator if ajax", ->
      enderElement = $ adapter.unwrap opentip.container
      loadingElement = enderElement.find "> .opentip > .loading-indicator > span"
      expect(loadingElement.length).to.be.ok()
      expect(loadingElement.html()).to.be "Loading..."

    it "should add a close button if hideTrigger = close", ->
      enderElement = $ adapter.unwrap opentip.container
      closeButton = enderElement.find "> .opentip > header > a.close > span"
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

      input = $("input", opentip.container).get(0)
      expect(document.activeElement).to.not.be input
      opentip._activateFirstInput()
      input.focus()
      expect(document.activeElement).to.be input



