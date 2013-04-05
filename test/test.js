(function() {
  var $;

  $ = jQuery;

  describe("Opentip", function() {
    var adapter;

    adapter = null;
    beforeEach(function() {
      return adapter = Opentip.adapter;
    });
    afterEach(function() {
      var elements;

      elements = $(".opentip-container");
      return elements.remove();
    });
    describe("constructor()", function() {
      before(function() {
        return sinon.stub(Opentip.prototype, "_setup");
      });
      after(function() {
        return Opentip.prototype._setup.restore();
      });
      it("arguments should be optional", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, "content");
        expect(opentip.content).to.equal("content");
        expect(adapter.unwrap(opentip.triggerElement)).to.equal(adapter.unwrap(element));
        opentip = new Opentip(element, "content", "title", {
          hideOn: "click"
        });
        expect(opentip.content).to.equal("content");
        expect(adapter.unwrap(opentip.triggerElement)).to.equal(adapter.unwrap(element));
        expect(opentip.options.hideOn).to.equal("click");
        expect(opentip.options.title).to.equal("title");
        opentip = new Opentip(element, {
          hideOn: "click"
        });
        expect(adapter.unwrap(opentip.triggerElement)).to.equal(adapter.unwrap(element));
        expect(opentip.options.hideOn).to.equal("click");
        expect(opentip.content).to.equal("");
        return expect(opentip.options.title).to.equal(void 0);
      });
      it("should always use the next tip id", function() {
        var element, opentip, opentip2, opentip3;

        element = document.createElement("div");
        Opentip.lastId = 0;
        opentip = new Opentip(element, "Test");
        opentip2 = new Opentip(element, "Test");
        opentip3 = new Opentip(element, "Test");
        expect(opentip.id).to.be(1);
        expect(opentip2.id).to.be(2);
        return expect(opentip3.id).to.be(3);
      });
      it("should use the href attribute if AJAX and an A element", function() {
        var element, opentip;

        element = $("<a href=\"http://testlink\">link</a>")[0];
        opentip = new Opentip(element, {
          ajax: true
        });
        return expect(opentip.options.ajax).to.equal("http://testlink");
      });
      it("should disable AJAX if neither URL or a link HREF is provided", function() {
        var element, opentip;

        element = $("<div>text</div>")[0];
        opentip = new Opentip(element, {
          ajax: true
        });
        return expect(opentip.options.ajax).to.be(false);
      });
      it("should disable a link if the event is onClick", function() {
        var element, opentip;

        sinon.stub(adapter, "observe");
        element = $("<a href=\"http://testlink\">link</a>")[0];
        sinon.stub(Opentip.prototype, "_setupObservers");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        expect(adapter.observe.calledOnce).to.be.ok();
        expect(adapter.observe.getCall(0).args[1]).to.equal("click");
        Opentip.prototype._setupObservers.restore();
        return adapter.observe.restore();
      });
      it("should take all options from selected style", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          style: "glass",
          showOn: "click"
        });
        expect(opentip.options.showOn).to.equal("click");
        expect(opentip.options.className).to.equal("glass");
        return expect(opentip.options.stemLength).to.equal(5);
      });
      it("the property 'style' should be handled the same as 'extends'", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          "extends": "glass",
          showOn: "click"
        });
        expect(opentip.options.showOn).to.equal("click");
        expect(opentip.options.className).to.equal("glass");
        return expect(opentip.options.stemLength).to.equal(5);
      });
      it("chaining incorrect styles should throw an exception", function() {
        var element;

        element = document.createElement("div");
        return expect(function() {
          return new Opentip(element, {
            "extends": "invalidstyle"
          });
        }).to.throwException(/Invalid style\: invalidstyle/);
      });
      it("chaining styles should work", function() {
        var element, opentip;

        element = document.createElement("div");
        Opentip.styles.test1 = {
          stemLength: 40
        };
        Opentip.styles.test2 = {
          "extends": "test1",
          title: "overwritten title"
        };
        Opentip.styles.test3 = {
          "extends": "test2",
          className: "test5",
          title: "some title"
        };
        opentip = new Opentip(element, {
          "extends": "test3",
          stemBase: 20
        });
        expect(opentip.options.className).to.equal("test5");
        expect(opentip.options.title).to.equal("some title");
        expect(opentip.options.stemLength).to.equal(40);
        return expect(opentip.options.stemBase).to.equal(20);
      });
      it("should set the options to fixed if a target is provided", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          target: true,
          fixed: false
        });
        return expect(opentip.options.fixed).to.be.ok();
      });
      it("should use provided stem", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          stem: "bottom",
          tipJoin: "topLeft"
        });
        return expect(opentip.options.stem.toString()).to.eql("bottom");
      });
      it("should take the tipJoint as stem if stem is just true", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          stem: true,
          tipJoint: "top left"
        });
        return expect(opentip.options.stem.toString()).to.eql("top left");
      });
      it("should use provided target", function() {
        var element, element2, opentip;

        element = adapter.create("<div></div>");
        element2 = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          target: element2
        });
        return expect(adapter.unwrap(opentip.options.target)).to.equal(adapter.unwrap(element2));
      });
      it("should take the triggerElement as target if target is just true", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          target: true
        });
        return expect(adapter.unwrap(opentip.options.target)).to.equal(adapter.unwrap(element));
      });
      it("currentStemPosition should be set to inital stemPosition", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          stem: "topLeft"
        });
        return expect(opentip.currentStem.toString()).to.eql("top left");
      });
      it("delay should be automatically set if none provided", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          delay: null,
          showOn: "click"
        });
        expect(opentip.options.delay).to.equal(0);
        opentip = new Opentip(element, {
          delay: null,
          showOn: "mouseover"
        });
        return expect(opentip.options.delay).to.equal(0.2);
      });
      it("the targetJoint should be the inverse of the tipJoint if none provided", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          tipJoint: "left"
        });
        expect(opentip.options.targetJoint.toString()).to.eql("right");
        opentip = new Opentip(element, {
          tipJoint: "top"
        });
        expect(opentip.options.targetJoint.toString()).to.eql("bottom");
        opentip = new Opentip(element, {
          tipJoint: "bottom right"
        });
        return expect(opentip.options.targetJoint.toString()).to.eql("top left");
      });
      it("should setup all trigger elements", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        expect(opentip.showTriggers[0].event).to.eql("click");
        expect(adapter.unwrap(opentip.showTriggers[0].element)).to.equal(adapter.unwrap(element));
        expect(opentip.showTriggersWhenVisible).to.eql([]);
        expect(opentip.hideTriggers).to.eql([]);
        opentip = new Opentip(element, {
          showOn: "creation"
        });
        expect(opentip.showTriggers).to.eql([]);
        expect(opentip.showTriggersWhenVisible).to.eql([]);
        return expect(opentip.hideTriggers).to.eql([]);
      });
      it("should copy options.hideTrigger onto options.hideTriggers", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          hideTrigger: "closeButton",
          hideTriggers: []
        });
        return expect(opentip.options.hideTriggers).to.eql(["closeButton"]);
      });
      it("should NOT copy options.hideTrigger onto options.hideTriggers when hideTriggers are set", function() {
        var element, opentip;

        element = adapter.create("<div></div>");
        opentip = new Opentip(element, {
          hideTrigger: "closeButton",
          hideTriggers: ["tip", "trigger"]
        });
        return expect(opentip.options.hideTriggers).to.eql(["tip", "trigger"]);
      });
      it("should attach itself to the elements `data-opentips` property", function() {
        var element, opentip, opentip2, opentip3;

        element = $("<div></div>")[0];
        expect(adapter.data(element, "opentips")).to.not.be.ok();
        opentip = new Opentip(element);
        expect(adapter.data(element, "opentips")).to.eql([opentip]);
        opentip2 = new Opentip(element);
        opentip3 = new Opentip(element);
        return expect(adapter.data(element, "opentips")).to.eql([opentip, opentip2, opentip3]);
      });
      it("should add itself to the Opentip.tips list", function() {
        var element, opentip1, opentip2;

        element = $("<div></div>")[0];
        Opentip.tips = [];
        opentip1 = new Opentip(element);
        opentip2 = new Opentip(element);
        expect(Opentip.tips.length).to.equal(2);
        expect(Opentip.tips[0]).to.equal(opentip1);
        return expect(Opentip.tips[1]).to.equal(opentip2);
      });
      return it("should rename ajaxCache to cache for backwards compatibility", function() {
        var element, opentip1, opentip2, _ref;

        element = $("<div></div>")[0];
        opentip1 = new Opentip(element, {
          ajaxCache: false
        });
        opentip2 = new Opentip(element, {
          ajaxCache: true
        });
        expect((opentip1.options.ajaxCache === (_ref = opentip2.options.ajaxCache) && _ref === void 0)).to.be.ok();
        expect(opentip1.options.cache).to.not.be.ok();
        return expect(opentip2.options.cache).to.be.ok();
      });
    });
    describe("init()", function() {
      return describe("showOn == creation", function() {
        var element;

        element = document.createElement("div");
        beforeEach(function() {
          return sinon.stub(Opentip.prototype, "prepareToShow");
        });
        afterEach(function() {
          return Opentip.prototype.prepareToShow.restore();
        });
        return it("should immediately call prepareToShow()", function() {
          var opentip;

          opentip = new Opentip(element, {
            showOn: "creation"
          });
          return expect(opentip.prepareToShow.callCount).to.equal(1);
        });
      });
    });
    describe("setContent()", function() {
      it("should update the content if tooltip currently visible", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        sinon.stub(opentip, "_updateElementContent");
        opentip.visible = false;
        opentip.setContent("TEST");
        expect(opentip.content).to.equal("TEST");
        opentip.visible = true;
        opentip.setContent("TEST2");
        expect(opentip.content).to.equal("TEST2");
        expect(opentip._updateElementContent.callCount).to.equal(1);
        return opentip._updateElementContent.restore();
      });
      return it("should not set the content directly if function", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        sinon.stub(opentip, "_updateElementContent");
        opentip.setContent(function() {
          return "TEST";
        });
        return expect(opentip.content).to.equal("");
      });
    });
    describe("_updateElementContent()", function() {
      it("should escape the content if @options.escapeContent", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, "<div><span></span></div>", {
          escapeContent: true
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
        opentip.show();
        return expect($(opentip.container).find(".ot-content").html()).to.be("&lt;div&gt;&lt;span&gt;&lt;/span&gt;&lt;/div&gt;");
      });
      it("should not escape the content if not @options.escapeContent", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, "<div><span></span></div>", {
          escapeContent: false
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
        opentip.show();
        return expect($(opentip.container).find(".ot-content > div > span").length).to.be(1);
      });
      it("should storeAndLock dimensions and reposition the element", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        sinon.stub(opentip, "_storeAndLockDimensions");
        sinon.stub(opentip, "reposition");
        opentip.visible = true;
        opentip._updateElementContent();
        expect(opentip._storeAndLockDimensions.callCount).to.equal(1);
        return expect(opentip.reposition.callCount).to.equal(1);
      });
      it("should execute the content function", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        sinon.stub(opentip.adapter, "find", function() {
          return "element";
        });
        opentip.visible = true;
        opentip.setContent(function() {
          return "BLA TEST";
        });
        expect(opentip.content).to.be("BLA TEST");
        return opentip.adapter.find.restore();
      });
      it("should only execute the content function once if cache:true", function() {
        var counter, element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click",
          cache: true
        });
        sinon.stub(opentip.adapter, "find", function() {
          return "element";
        });
        opentip.visible = true;
        counter = 0;
        opentip.setContent(function() {
          return "count" + (counter++);
        });
        expect(opentip.content).to.be("count0");
        opentip._updateElementContent();
        opentip._updateElementContent();
        expect(opentip.content).to.be("count0");
        return opentip.adapter.find.restore();
      });
      it("should execute the content function multiple times if cache:false", function() {
        var counter, element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click",
          cache: false
        });
        sinon.stub(opentip.adapter, "find", function() {
          return "element";
        });
        opentip.visible = true;
        counter = 0;
        opentip.setContent(function() {
          return "count" + (counter++);
        });
        expect(opentip.content).to.be("count0");
        opentip._updateElementContent();
        opentip._updateElementContent();
        expect(opentip.content).to.be("count2");
        return opentip.adapter.find.restore();
      });
      return it("should only update the HTML elements if the content has been changed", function() {
        var element, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, {
          showOn: "click"
        });
        sinon.stub(opentip.adapter, "find", function() {
          return "element";
        });
        sinon.stub(opentip.adapter, "update", function() {});
        opentip.visible = true;
        opentip.setContent("TEST");
        expect(opentip.adapter.update.callCount).to.be(1);
        opentip._updateElementContent();
        opentip._updateElementContent();
        expect(opentip.adapter.update.callCount).to.be(1);
        opentip.setContent("TEST2");
        expect(opentip.adapter.update.callCount).to.be(2);
        opentip.adapter.find.restore();
        return opentip.adapter.update.restore();
      });
    });
    describe("_buildContainer()", function() {
      var element, opentip;

      element = document.createElement("div");
      opentip = null;
      beforeEach(function() {
        opentip = new Opentip(element, {
          style: "glass",
          showEffect: "appear",
          hideEffect: "fade"
        });
        return opentip._setup();
      });
      it("should set the id", function() {
        return expect(adapter.attr(opentip.container, "id")).to.equal("opentip-" + opentip.id);
      });
      return it("should set the classes", function() {
        var enderElement;

        enderElement = $(adapter.unwrap(opentip.container));
        expect(enderElement.hasClass("opentip-container")).to.be.ok();
        expect(enderElement.hasClass("ot-hidden")).to.be.ok();
        expect(enderElement.hasClass("style-glass")).to.be.ok();
        expect(enderElement.hasClass("ot-show-effect-appear")).to.be.ok();
        return expect(enderElement.hasClass("ot-hide-effect-fade")).to.be.ok();
      });
    });
    describe("_buildElements()", function() {
      var element, opentip;

      element = opentip = null;
      beforeEach(function() {
        element = document.createElement("div");
        opentip = new Opentip(element, "the content", "the title", {
          hideTrigger: "closeButton",
          stem: "top left",
          ajax: "bla"
        });
        opentip._setup();
        return opentip._buildElements();
      });
      it("should add a h1 if title is provided", function() {
        var enderElement, headerElement;

        enderElement = $(adapter.unwrap(opentip.container));
        headerElement = enderElement.find("> .opentip > .ot-header > h1");
        expect(headerElement.length).to.be.ok();
        return expect(headerElement.html()).to.be("the title");
      });
      it("should add a loading indicator if ajax", function() {
        var enderElement, loadingElement;

        enderElement = $(adapter.unwrap(opentip.container));
        loadingElement = enderElement.find("> .opentip > .ot-loading-indicator > span");
        expect(loadingElement.length).to.be.ok();
        return expect(loadingElement.html()).to.be("↻");
      });
      return it("should add a close button if hideTrigger = close", function() {
        var closeButton, enderElement;

        enderElement = $(adapter.unwrap(opentip.container));
        closeButton = enderElement.find("> .opentip > .ot-header > a.ot-close > span");
        expect(closeButton.length).to.be.ok();
        return expect(closeButton.html()).to.be("Close");
      });
    });
    describe("addAdapter()", function() {
      it("should set the current adapter, and add the adapter to the list", function() {
        var testAdapter;

        expect(Opentip.adapters.testa).to.not.be.ok();
        testAdapter = {
          name: "testa"
        };
        Opentip.addAdapter(testAdapter);
        return expect(Opentip.adapters.testa).to.equal(testAdapter);
      });
      return it("should use adapter.domReady to call findElements() with it");
    });
    describe("_setupObservers()", function() {
      return it("should never setup the same observers twice");
    });
    describe("_searchAndActivateCloseButtons()", function() {
      return it("should do what it says");
    });
    return describe("_activateFirstInput()", function() {
      return it("should do what it says", function() {
        var element, input, opentip;

        element = document.createElement("div");
        opentip = new Opentip(element, "<input /><textarea>", {
          escapeContent: false
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
        opentip.show();
        input = $("input", opentip.container)[0];
        expect(document.activeElement).to.not.be(input);
        opentip._activateFirstInput();
        input.focus();
        return expect(document.activeElement).to.be(input);
      });
    });
  });

}).call(this);

(function() {
  var $,
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;

  describe("Opentip - Startup", function() {
    var adapter, opentip;

    adapter = Opentip.adapter;
    opentip = null;
    afterEach(function() {
      var prop, _ref;

      for (prop in opentip) {
        if (!__hasProp.call(opentip, prop)) continue;
        if ((_ref = opentip[prop]) != null) {
          if (typeof _ref.restore === "function") {
            _ref.restore();
          }
        }
      }
      if (opentip != null) {
        if (typeof opentip.deactivate === "function") {
          opentip.deactivate();
        }
      }
      $("[data-ot]").remove();
      return $(".opentip-container").remove();
    });
    it("should find all elements with data-ot()", function() {
      var trigger;

      trigger = $("<div data-ot=\"Content text\"></div>")[0];
      $(document.body).append(trigger);
      Opentip.findElements();
      expect(adapter.data(trigger, "opentips")).to.be.an(Array);
      expect(adapter.data(trigger, "opentips").length).to.equal(1);
      return expect(adapter.data(trigger, "opentips")[0]).to.be.an(Opentip);
    });
    it("should take configuration from data- attributes", function() {
      var trigger;

      trigger = $("<div data-ot=\"Content text\" data-ot-show-on=\"click\" data-ot-hide-trigger=\"closeButton\"></div>")[0];
      $(document.body).append(trigger);
      Opentip.findElements();
      expect(adapter.data(trigger, "opentips")[0]).to.be.an(Opentip);
      opentip = adapter.data(trigger, "opentips")[0];
      expect(opentip.options.hideTrigger).to.eql("closeButton");
      return expect(opentip.options.showOn).to.eql("click");
    });
    return it("should properly parse boolean data- attributes", function() {
      var trigger;

      trigger = $("<div data-ot=\"Content text\" data-ot-shadow=\"yes\" data-ot-auto-offset=\"no\" data-ot-contain-in-viewport=\"false\"></div>")[0];
      $(document.body).append(trigger);
      Opentip.findElements();
      opentip = adapter.data(trigger, "opentips")[0];
      expect(opentip.options.shadow).to.be(true);
      expect(opentip.options.autoOffset).to.be(false);
      return expect(opentip.options.containInViewport).to.be(false);
    });
  });

}).call(this);

(function() {
  var $,
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;

  describe("Opentip - Appearing", function() {
    var adapter, opentip, triggerElementExists;

    adapter = Opentip.adapter;
    opentip = null;
    triggerElementExists = true;
    beforeEach(function() {
      return triggerElementExists = true;
    });
    afterEach(function() {
      var prop, _ref;

      if (opentip) {
        for (prop in opentip) {
          if (!__hasProp.call(opentip, prop)) continue;
          if ((_ref = opentip[prop]) != null) {
            if (typeof _ref.restore === "function") {
              _ref.restore();
            }
          }
        }
        opentip.deactivate();
      }
      return $(".opentip-container").remove();
    });
    describe("prepareToShow()", function() {
      beforeEach(function() {
        triggerElementExists = false;
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0
        });
        return sinon.stub(opentip, "_triggerElementExists", function() {
          return triggerElementExists;
        });
      });
      it("should call _setup if no container yet", function() {
        sinon.spy(opentip, "_setup");
        opentip.prepareToShow();
        opentip.prepareToShow();
        return expect(opentip._setup.calledOnce).to.be.ok();
      });
      it("should always abort a hiding process", function() {
        sinon.stub(opentip, "_abortHiding");
        opentip.prepareToShow();
        return expect(opentip._abortHiding.callCount).to.be(1);
      });
      it("even when aborting because it's already visible", function() {
        sinon.stub(opentip, "_abortHiding");
        opentip.visible = true;
        opentip.prepareToShow();
        return expect(opentip._abortHiding.callCount).to.be(1);
      });
      it("should abort when already visible", function() {
        expect(opentip.preparingToShow).to.not.be.ok();
        opentip.visible = true;
        opentip.prepareToShow();
        expect(opentip.preparingToShow).to.not.be.ok();
        opentip.visible = false;
        opentip.prepareToShow();
        return expect(opentip.preparingToShow).to.be.ok();
      });
      it("should log that it's preparing to show", function() {
        sinon.stub(opentip, "debug");
        opentip.prepareToShow();
        expect(opentip.debug.callCount).to.be(2);
        expect(opentip.debug.getCall(0).args[0]).to.be("Showing in 0s.");
        return expect(opentip.debug.getCall(1).args[0]).to.be("Setting up the tooltip.");
      });
      it("should setup observers for 'showing'", function() {
        sinon.stub(opentip, "_setupObservers");
        opentip.prepareToShow();
        expect(opentip._setupObservers.callCount).to.be(1);
        expect(opentip._setupObservers.getCall(0).args[0]).to.be("-hidden");
        expect(opentip._setupObservers.getCall(0).args[1]).to.be("-hiding");
        return expect(opentip._setupObservers.getCall(0).args[2]).to.be("showing");
      });
      it("should start following mouseposition", function() {
        sinon.stub(opentip, "_followMousePosition");
        opentip.prepareToShow();
        return expect(opentip._followMousePosition.callCount).to.be(1);
      });
      it("should reposition itself «On se redresse!»", function() {
        sinon.stub(opentip, "reposition");
        opentip.prepareToShow();
        return expect(opentip.reposition.callCount).to.be(1);
      });
      return it("should call show() after the specified delay (50ms)", function(done) {
        opentip.options.delay = 0.05;
        sinon.stub(opentip, "show", function() {
          return done();
        });
        return opentip.prepareToShow();
      });
    });
    describe("show()", function() {
      beforeEach(function() {
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0
        });
        return sinon.stub(opentip, "_triggerElementExists", function() {
          return triggerElementExists;
        });
      });
      it("should call _setup if no container yet", function() {
        sinon.spy(opentip, "_setup");
        opentip.show();
        opentip.show();
        return expect(opentip._setup.calledOnce).to.be.ok();
      });
      it("should clear all timeouts", function() {
        triggerElementExists = false;
        sinon.stub(opentip, "_clearTimeouts");
        opentip.show();
        return expect(opentip._clearTimeouts.callCount).to.be.above(0);
      });
      it("should not clear all timeouts when already visible", function() {
        triggerElementExists = false;
        sinon.stub(opentip, "_clearTimeouts");
        opentip.visible = true;
        opentip.show();
        return expect(opentip._clearTimeouts.callCount).to.be(0);
      });
      it("should abort if already visible", function() {
        triggerElementExists = false;
        sinon.stub(opentip, "debug");
        opentip.visible = true;
        opentip.show();
        return expect(opentip.debug.callCount).to.be(0);
      });
      it("should log that it's showing", function() {
        sinon.stub(opentip, "debug");
        opentip.show();
        expect(opentip.debug.callCount).to.be.above(1);
        return expect(opentip.debug.args[0][0]).to.be("Showing now.");
      });
      it("should set visible to true and preparingToShow to false", function() {
        opentip.preparingToShow = true;
        opentip.show();
        expect(opentip.visible).to.be.ok();
        return expect(opentip.preparingToShow).to.not.be.ok();
      });
      it("should use _ensureViewportContaintment if options.containInViewport", function() {
        sinon.spy(opentip, "_ensureViewportContainment");
        sinon.stub(opentip, "getPosition", function() {
          return {
            x: 0,
            y: 0
          };
        });
        opentip.show();
        return expect(opentip._ensureViewportContainment.callCount).to.be.above(1);
      });
      return it("should not use _ensureViewportContaintment if !options.containInViewport", function() {
        opentip.options.containInViewport = false;
        sinon.stub(opentip, "_ensureViewportContainment");
        opentip.show();
        return expect(opentip._ensureViewportContainment.callCount).to.be(0);
      });
    });
    describe("grouped Opentips", function() {
      it("should hide all other opentips", function() {
        var opentip2, opentip3;

        Opentip.tips = [];
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0,
          group: "test"
        });
        opentip2 = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0,
          group: "test"
        });
        opentip3 = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0,
          group: "test"
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        sinon.stub(opentip2, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        sinon.stub(opentip3, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        opentip.show();
        expect(opentip.visible).to.be.ok();
        expect(opentip2.visible).to.not.be.ok();
        expect(opentip3.visible).to.not.be.ok();
        opentip2.show();
        expect(opentip.visible).to.not.be.ok();
        expect(opentip2.visible).to.be.ok();
        expect(opentip3.visible).to.not.be.ok();
        opentip3.show();
        expect(opentip.visible).to.not.be.ok();
        expect(opentip2.visible).to.not.be.ok();
        expect(opentip3.visible).to.be.ok();
        opentip.deactivate();
        opentip2.deactivate();
        return opentip3.deactivate();
      });
      return it("should abort showing other opentips", function() {
        var opentip2, opentip3;

        Opentip.tips = [];
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 1000,
          group: "test"
        });
        opentip2 = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 1000,
          group: "test"
        });
        opentip3 = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 1000,
          group: "test"
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        sinon.stub(opentip2, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        sinon.stub(opentip3, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        opentip.prepareToShow();
        expect(opentip.visible).to.not.be.ok();
        expect(opentip.preparingToShow).to.be.ok();
        expect(opentip2.visible).to.not.be.ok();
        expect(opentip2.preparingToShow).to.not.be.ok();
        opentip2.prepareToShow();
        expect(opentip.visible).to.not.be.ok();
        expect(opentip.preparingToShow).to.not.be.ok();
        expect(opentip2.visible).to.not.be.ok();
        expect(opentip2.preparingToShow).to.be.ok();
        opentip3.show();
        expect(opentip.visible).to.not.be.ok();
        expect(opentip.preparingToShow).to.not.be.ok();
        expect(opentip2.visible).to.not.be.ok();
        expect(opentip2.preparingToShow).to.not.be.ok();
        opentip.deactivate();
        opentip2.deactivate();
        return opentip3.deactivate();
      });
    });
    describe("events", function() {
      var element, event, testEvent, _i, _len, _ref, _results;

      element = "";
      beforeEach(function() {
        return element = document.createElement("div");
      });
      testEvent = function(opentip, event, done) {
        expect(opentip.visible).to.not.be.ok();
        Test.triggerEvent(element, event);
        expect(opentip.preparingToShow).to.be.ok();
        expect(opentip.visible).to.not.be.ok();
        return setTimeout(function() {
          var e;

          try {
            expect(opentip.visible).to.be.ok();
            return done();
          } catch (_error) {
            e = _error;
            return done(e);
          }
        }, 2);
      };
      _ref = ["click", "mouseover", "focus"];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        event = _ref[_i];
        _results.push(it("should show on " + event, function(done) {
          opentip = new Opentip(element, "test", {
            delay: 0,
            showOn: event
          });
          sinon.stub(opentip, "_triggerElementExists", function() {
            return triggerElementExists;
          });
          return testEvent(opentip, event, done);
        }));
      }
      return _results;
    });
    describe("hide", function() {
      return it("should remove HTML elements if removeElementsOnHide: true", function(done) {
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0,
          removeElementsOnHide: true,
          hideEffectDuration: 0,
          hideDelay: 0
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
        opentip.show();
        expect($("#opentip-" + opentip.id).length).to.be(1);
        opentip.hide();
        return setTimeout((function() {
          expect($("#opentip-" + opentip.id).length).to.be(0);
          opentip.show();
          expect($("#opentip-" + opentip.id).length).to.be(1);
          opentip = null;
          return done();
        }), 100);
      });
    });
    return describe("visible", function() {
      var $element, element, span;

      $element = null;
      element = null;
      span = null;
      beforeEach(function() {
        $element = $("<div><div><span></span></div></div>");
        span = $element.find("span");
        return element = $element[0];
      });
      return it("should activate all hide buttons", function(done) {
        var closeClass;

        closeClass = Opentip.prototype["class"].close;
        opentip = new Opentip(element, "<a class=\"" + closeClass + "\">close</a>", {
          escape: false,
          delay: 0,
          hideDelay: 0,
          hideTrigger: "closeButton",
          hideOn: "click"
        });
        sinon.stub(opentip, "_triggerElementExists", function() {
          return triggerElementExists;
        });
        sinon.stub(opentip, "prepareToHide");
        opentip.prepareToShow();
        setTimeout(function() {
          var closeButtons, e;

          try {
            closeButtons = $(opentip.container).find("." + closeClass);
            expect(closeButtons.length).to.be(2);
            expect(opentip.prepareToHide.callCount).to.be(0);
          } catch (_error) {
            e = _error;
            done(e);
            return;
          }
          Test.triggerEvent(closeButtons[0], "click");
          return setTimeout(function() {
            try {
              expect(opentip.prepareToHide.callCount).to.be(1);
              return done();
            } catch (_error) {
              e = _error;
              return done(e);
            }
          }, 4);
        });
        return 4;
      });
    });
  });

}).call(this);

(function() {
  var $;

  $ = jQuery;

  describe("Opentip - Positioning", function() {
    var adapter, opentip, triggerElementExists;

    adapter = Opentip.adapter;
    opentip = null;
    triggerElementExists = true;
    beforeEach(function() {
      return triggerElementExists = true;
    });
    afterEach(function() {
      var prop, _ref;

      for (prop in opentip) {
        if ((_ref = opentip[prop]) != null) {
          if (typeof _ref.restore === "function") {
            _ref.restore();
          }
        }
      }
      return $(".opentip-container").remove();
    });
    describe("fixed", function() {
      var element;

      element = adapter.create("<div style=\"display: block; position: absolute; top: 500px; left: 500px; width: 50px; height: 50px;\"></div>");
      beforeEach(function() {
        return adapter.append(document.body, element);
      });
      afterEach(function() {
        return $(adapter.unwrap(element)).remove();
      });
      return describe("without autoOffset", function() {
        it("should correctly position opentip without border and stem", function() {
          var elementOffset;

          opentip = new Opentip(element, "Test", {
            delay: 0,
            target: true,
            borderWidth: 0,
            stem: false,
            offset: [0, 0],
            autoOffset: false
          });
          opentip._setup();
          elementOffset = adapter.offset(element);
          expect(elementOffset).to.eql({
            left: 500,
            top: 500
          });
          opentip.reposition();
          return expect(opentip.currentPosition).to.eql({
            left: 550,
            top: 550
          });
        });
        it("should correctly position opentip with", function() {
          var elementOffset;

          opentip = new Opentip(element, "Test", {
            delay: 0,
            target: true,
            borderWidth: 10,
            stem: false,
            offset: [0, 0],
            autoOffset: false
          });
          opentip._setup();
          elementOffset = adapter.offset(element);
          opentip.reposition();
          return expect(opentip.currentPosition).to.eql({
            left: 560,
            top: 560
          });
        });
        it("should correctly position opentip with stem on the left", function() {
          var elementOffset;

          opentip = new Opentip(element, "Test", {
            delay: 0,
            target: true,
            borderWidth: 0,
            stem: true,
            tipJoint: "top left",
            stemLength: 5,
            offset: [0, 0],
            autoOffset: false
          });
          opentip._setup();
          elementOffset = adapter.offset(element);
          opentip.reposition();
          return expect(opentip.currentPosition).to.eql({
            left: 550,
            top: 550
          });
        });
        it("should correctly position opentip on the bottom right", function() {
          var elementDimensions, elementOffset;

          opentip = new Opentip(element, "Test", {
            delay: 0,
            target: true,
            borderWidth: 0,
            stem: false,
            tipJoint: "bottom right",
            offset: [0, 0],
            autoOffset: false
          });
          opentip._setup();
          opentip.dimensions = {
            width: 200,
            height: 200
          };
          elementOffset = adapter.offset(element);
          elementDimensions = adapter.dimensions(element);
          expect(elementDimensions).to.eql({
            width: 50,
            height: 50
          });
          opentip.reposition();
          return expect(opentip.currentPosition).to.eql({
            left: 300,
            top: 300
          });
        });
        return it("should correctly position opentip on the bottom right with stem", function() {
          var elementDimensions, elementOffset;

          opentip = new Opentip(element, "Test", {
            delay: 0,
            target: true,
            borderWidth: 0,
            stem: true,
            tipJoint: "bottom right",
            stemLength: 10,
            offset: [0, 0],
            autoOffset: false
          });
          opentip._setup();
          opentip.dimensions = {
            width: 200,
            height: 200
          };
          elementOffset = adapter.offset(element);
          elementDimensions = adapter.dimensions(element);
          expect(elementDimensions).to.eql({
            width: 50,
            height: 50
          });
          opentip.reposition();
          return expect(opentip.currentPosition).to.eql({
            left: 300,
            top: 300
          });
        });
      });
    });
    describe("following mouse", function() {
      return it("should correctly position opentip when following mouse");
    });
    return describe("_ensureViewportContainment()", function() {
      it("should put the tooltip on the other side when it's sticking out");
      it("shouldn't do anything if the viewport is smaller than the tooltip");
      return it("should revert if the tooltip sticks out the other side as well");
    });
  });

}).call(this);

(function() {
  var $,
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;

  describe("Opentip - Drawing", function() {
    var adapter, opentip;

    adapter = Opentip.adapter;
    opentip = null;
    afterEach(function() {
      var prop, _ref;

      for (prop in opentip) {
        if (!__hasProp.call(opentip, prop)) continue;
        if ((_ref = opentip[prop]) != null) {
          if (typeof _ref.restore === "function") {
            _ref.restore();
          }
        }
      }
      if (opentip != null) {
        if (typeof opentip.deactivate === "function") {
          opentip.deactivate();
        }
      }
      return $(".opentip-container").remove();
    });
    describe("_draw()", function() {
      beforeEach(function() {
        opentip = new Opentip(adapter.create("<div></div>"), "Test", {
          delay: 0
        });
        return sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
      });
      it("should abort if @redraw not set", function() {
        sinon.stub(opentip, "debug");
        opentip.backgroundCanvas = document.createElement("canvas");
        opentip.redraw = false;
        opentip._draw();
        return expect(opentip.debug.callCount).to.be(0);
      });
      it("should abort if no canvas not set", function() {
        sinon.stub(opentip, "debug");
        opentip.redraw = true;
        opentip._draw();
        return expect(opentip.debug.callCount).to.be(0);
      });
      it("should draw if canvas and @redraw", function() {
        sinon.stub(opentip, "debug");
        opentip._setup();
        opentip.backgroundCanvas = document.createElement("canvas");
        opentip.redraw = true;
        opentip._draw();
        expect(opentip.debug.callCount).to.be.above(0);
        return expect(opentip.debug.args[1][0]).to.be("Drawing background.");
      });
      it("should add the stem classes", function() {
        var unwrappedContainer;

        sinon.stub(opentip, "debug");
        opentip._setup();
        opentip.backgroundCanvas = document.createElement("canvas");
        opentip.currentStem = new Opentip.Joint("bottom left");
        opentip.redraw = true;
        opentip._draw();
        unwrappedContainer = Opentip.adapter.unwrap(opentip.container);
        expect(unwrappedContainer.classList.contains("stem-bottom")).to.be.ok();
        expect(unwrappedContainer.classList.contains("stem-left")).to.be.ok();
        opentip.currentStem = new Opentip.Joint("right middle");
        opentip.redraw = true;
        opentip._draw();
        expect(unwrappedContainer.classList.contains("stem-bottom")).not.to.be.ok();
        expect(unwrappedContainer.classList.contains("stem-left")).not.to.be.ok();
        expect(unwrappedContainer.classList.contains("stem-middle")).to.be.ok();
        return expect(unwrappedContainer.classList.contains("stem-right")).to.be.ok();
      });
      it("should set the correct width of the canvas");
      return it("should set the correct offset of the canvas");
    });
    describe("with close button", function() {
      var createAndShowTooltip, element, options;

      options = {};
      element = null;
      beforeEach(function() {
        element = $("<div />");
        $(document.body).append(element);
        sinon.stub(Opentip.adapter, "dimensions", function() {
          return {
            width: 199,
            height: 100
          };
        });
        return options = {
          delay: 0,
          stem: false,
          hideTrigger: "closeButton",
          closeButtonRadius: 20,
          closeButtonOffset: [0, 10],
          closeButtonCrossSize: 10,
          closeButtonLinkOverscan: 5,
          borderWidth: 0,
          containInViewport: false
        };
      });
      afterEach(function() {
        element.remove();
        return Opentip.adapter.dimensions.restore();
      });
      createAndShowTooltip = function() {
        opentip = new Opentip(element.get(0), "Test", options);
        sinon.stub(opentip, "_triggerElementExists", function() {
          return true;
        });
        opentip.show();
        expect(opentip._dimensionsEqual(opentip.dimensions, {
          width: 200,
          height: 100
        })).to.be.ok();
        return opentip;
      };
      it("should position the close link when no border", function() {
        var el;

        options.borderWidth = 0;
        options.closeButtonOffset = [0, 10];
        createAndShowTooltip();
        el = adapter.unwrap(opentip.closeButtonElement);
        expect(el.style.left).to.be("190px");
        expect(el.style.top).to.be("0px");
        expect(el.style.width).to.be("20px");
        return expect(el.style.height).to.be("20px");
      });
      it("should position the close link when border and different overscan", function() {
        var el;

        options.borderWidth = 1;
        options.closeButtonLinkOverscan = 10;
        createAndShowTooltip();
        el = adapter.unwrap(opentip.closeButtonElement);
        expect(el.style.left).to.be("185px");
        expect(el.style.top).to.be("-5px");
        expect(el.style.width).to.be("30px");
        return expect(el.style.height).to.be("30px");
      });
      it("should position the close link with different offsets and overscans", function() {
        var el;

        options.closeButtonOffset = [10, 5];
        options.closeButtonCrossSize = 10;
        options.closeButtonLinkOverscan = 0;
        createAndShowTooltip();
        el = adapter.unwrap(opentip.closeButtonElement);
        expect(el.style.left).to.be("185px");
        expect(el.style.top).to.be("0px");
        expect(el.style.width).to.be("10px");
        return expect(el.style.height).to.be("10px");
      });
      return it("should correctly position the close link on the left when stem on top right", function() {
        var el;

        options.closeButtonOffset = [20, 17];
        options.closeButtonCrossSize = 12;
        options.closeButtonLinkOverscan = 5;
        options.stem = "top right";
        opentip = createAndShowTooltip();
        el = adapter.unwrap(opentip.closeButtonElement);
        expect(opentip.options.stem.toString()).to.be("top right");
        expect(el.style.left).to.be("9px");
        expect(el.style.top).to.be("6px");
        expect(el.style.width).to.be("22px");
        return expect(el.style.height).to.be("22px");
      });
    });
    describe("_getPathStemMeasures()", function() {
      it("should just return the same measures if borderWidth is 0", function() {
        var stemBase, stemLength, _ref;

        _ref = opentip._getPathStemMeasures(6, 10, 0), stemBase = _ref.stemBase, stemLength = _ref.stemLength;
        expect(stemBase).to.be(6);
        return expect(stemLength).to.be(10);
      });
      it("should properly calculate the pathStem information if borderWidth > 0", function() {
        var stemBase, stemLength, _ref;

        _ref = opentip._getPathStemMeasures(6, 10, 3), stemBase = _ref.stemBase, stemLength = _ref.stemLength;
        expect(stemBase).to.be(3.767908047326835);
        return expect(stemLength).to.be(6.2798467455447256);
      });
      return it("should throw an exception if the measures aren't right", function() {
        return expect(function() {
          return opentip._getPathStemMeasures(6, 10, 40);
        }).to.throwError();
      });
    });
    return describe("_getColor()", function() {
      var cavans, ctx, dimensions, gradient;

      dimensions = {
        width: 200,
        height: 100
      };
      cavans = document.createElement("canvas");
      ctx = cavans.getContext("2d");
      gradient = ctx.createLinearGradient(0, 0, 1, 1);
      ctx = sinon.stub(ctx);
      gradient = sinon.stub(gradient);
      ctx.createLinearGradient.returns(gradient);
      it("should just return the hex color", function() {
        return expect(Opentip.prototype._getColor(ctx, dimensions, "#f00")).to.be("#f00");
      });
      it("should just return rgba color", function() {
        return expect(Opentip.prototype._getColor(ctx, dimensions, "rgba(0, 0, 0, 0.3)")).to.be("rgba(0, 0, 0, 0.3)");
      });
      it("should just return named color", function() {
        return expect(Opentip.prototype._getColor(ctx, dimensions, "red")).to.be("red");
      });
      return it("should create and return gradient", function() {
        var color;

        color = Opentip.prototype._getColor(ctx, dimensions, [[0, "black"], [1, "white"]]);
        expect(gradient.addColorStop.callCount).to.be(2);
        return expect(color).to.be(gradient);
      });
    });
  });

}).call(this);

(function() {
  var $,
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;

  describe("Opentip - AJAX", function() {
    var adapter, opentip, triggerElementExists;

    adapter = Opentip.adapter;
    opentip = null;
    triggerElementExists = true;
    beforeEach(function() {
      return triggerElementExists = true;
    });
    afterEach(function() {
      var prop, _ref;

      for (prop in opentip) {
        if (!__hasProp.call(opentip, prop)) continue;
        if ((_ref = opentip[prop]) != null) {
          if (typeof _ref.restore === "function") {
            _ref.restore();
          }
        }
      }
      opentip.deactivate();
      return $(".opentip-container").remove();
    });
    return describe("_loadAjax()", function() {
      describe("on success", function() {
        beforeEach(function() {
          return sinon.stub(adapter, "ajax", function(options) {
            options.onSuccess("response text");
            return options.onComplete();
          });
        });
        afterEach(function() {
          return adapter.ajax.restore();
        });
        it("should use adapter.ajax", function() {
          opentip = new Opentip(adapter.create("<div></div>"), "Test", {
            ajax: "http://www.test.com",
            ajaxMethod: "post"
          });
          opentip._setup();
          opentip._loadAjax();
          expect(adapter.ajax.callCount).to.be(1);
          expect(adapter.ajax.args[0][0].url).to.equal("http://www.test.com");
          return expect(adapter.ajax.args[0][0].method).to.equal("post");
        });
        it("should be called by show() and update the content (only once!)", function() {
          opentip = new Opentip(adapter.create("<div></div>"), "Test", {
            ajax: "http://www.test.com",
            ajaxMethod: "post",
            cache: true
          });
          sinon.stub(opentip, "_triggerElementExists", function() {
            return true;
          });
          sinon.spy(opentip, "setContent");
          opentip.show();
          opentip.hide();
          opentip.show();
          opentip.hide();
          opentip.show();
          opentip.hide();
          expect(adapter.ajax.callCount).to.be(1);
          expect(opentip.setContent.callCount).to.be(2);
          return expect(opentip.content).to.be("response text");
        });
        return it("if cache: false, should be called by show() and update the content every time show is called", function() {
          opentip = new Opentip(adapter.create("<div></div>"), "Test", {
            ajax: "http://www.test.com",
            ajaxMethod: "post",
            cache: false
          });
          sinon.stub(opentip, "_triggerElementExists", function() {
            return true;
          });
          sinon.spy(opentip, "setContent");
          opentip.show();
          opentip.hide();
          opentip.show();
          opentip.hide();
          opentip.show();
          opentip.hide();
          expect(adapter.ajax.callCount).to.be(3);
          return expect(opentip.setContent.callCount).to.be(6);
        });
      });
      return describe("on error", function() {
        beforeEach(function() {
          return sinon.stub(adapter, "ajax", function(options) {
            return options.onError("Some error");
          });
        });
        afterEach(function() {
          return adapter.ajax.restore();
        });
        return it("should use the options.ajaxErrorMessage on failure", function() {
          opentip = new Opentip(adapter.create("<div></div>"), "Test", {
            ajax: "http://www.test.com",
            ajaxMethod: "post",
            ajaxErrorMessage: "No download dude."
          });
          opentip._setup();
          expect(opentip.options.ajaxErrorMessage).to.be("No download dude.");
          expect(opentip.content).to.be("Test");
          opentip._loadAjax();
          return expect(opentip.content).to.be(opentip.options.ajaxErrorMessage);
        });
      });
    });
  });

}).call(this);

(function() {
  describe("utils", function() {
    var adapter;

    adapter = Opentip.adapter;
    describe("debug()", function() {
      var consoleDebug;

      consoleDebug = console.debug;
      beforeEach(function() {
        return sinon.stub(console, "debug");
      });
      afterEach(function() {
        return console.debug.restore();
      });
      it("should only debug when Opentip.debug == true", function() {
        Opentip.debug = false;
        Opentip.prototype.debug("test");
        expect(console.debug.called).to.not.be.ok();
        Opentip.debug = true;
        Opentip.prototype.debug("test");
        return expect(console.debug.called).to.be.ok();
      });
      return it("should include the opentip id", function() {
        var opentip;

        Opentip.debug = true;
        opentip = new Opentip(document.createElement("span"));
        opentip.debug("test");
        return expect(console.debug.getCall(0).args[0]).to.be("#" + opentip.id + " |");
      });
    });
    describe("ucfirst()", function() {
      return it("should transform the first character to uppercase", function() {
        return expect(Opentip.prototype.ucfirst("abc def")).to.equal("Abc def");
      });
    });
    describe("dasherize()", function() {
      return it("should transform camelized words into dasherized", function() {
        return expect(Opentip.prototype.dasherize("testAbcHoiTEST")).to.equal("test-abc-hoi-t-e-s-t");
      });
    });
    describe("_positionsEqual()", function() {
      return it("should properly compare positions", function() {
        var eq;

        eq = Opentip.prototype._positionsEqual;
        expect(eq({
          left: 0,
          top: 0
        }, {
          left: 0,
          top: 0
        })).to.be.ok();
        expect(eq({
          left: 100,
          top: 20
        }, {
          left: 100,
          top: 20
        })).to.be.ok();
        expect(eq({
          left: 100,
          top: 20
        }, {
          left: 101,
          top: 20
        })).to.not.be.ok();
        expect(eq(null, {
          left: 101,
          top: 20
        })).to.not.be.ok();
        return expect(eq(null, null)).to.not.be.ok();
      });
    });
    describe("_dimensionsEqual()", function() {
      return it("should properly compare dimensions", function() {
        var eq;

        eq = Opentip.prototype._dimensionsEqual;
        expect(eq({
          width: 0,
          height: 0
        }, {
          width: 0,
          height: 0
        })).to.be.ok();
        expect(eq({
          width: 100,
          height: 20
        }, {
          width: 100,
          height: 20
        })).to.be.ok();
        expect(eq({
          width: 100,
          height: 20
        }, {
          width: 101,
          height: 20
        })).to.not.be.ok();
        expect(eq(null, {
          width: 101,
          height: 20
        })).to.not.be.ok();
        return expect(eq(null, null)).to.not.be.ok();
      });
    });
    describe("setCss3Style()", function() {
      var opentip;

      opentip = new Opentip(adapter.create("<div></div>"), "Test");
      return it("should set the style for all vendors", function() {
        var element, opacity, prop, transitionDuration, vendor, _i, _len, _ref;

        element = document.createElement("div");
        opentip.setCss3Style(element, {
          opacity: "0.5",
          transitionDuration: "1s"
        });
        transitionDuration = false;
        opacity = false;
        _ref = ["", "Khtml", "Ms", "O", "Moz", "Webkit"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          vendor = _ref[_i];
          prop = vendor ? "" + vendor + "TransitionDuration" : "transitionDuration";
          if (element.style[prop] === "1s") {
            transitionDuration = true;
          }
          prop = vendor ? "" + vendor + "Opacity" : "opacity";
          if (element.style[prop] === "0.5") {
            opacity = true;
          }
        }
        expect(transitionDuration).to.be(true);
        return expect(opacity).to.be(true);
      });
    });
    describe("defer()", function() {
      return it("should call the callback as soon as possible");
    });
    return describe("setTimeout()", function() {
      return it("should wrap window.setTimeout but with seconds");
    });
  });

}).call(this);

(function() {
  var extend,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  extend = function() {
    var key, source, sources, target, val, _i, _len;

    target = arguments[0], sources = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
    for (_i = 0, _len = sources.length; _i < _len; _i++) {
      source = sources[_i];
      for (key in source) {
        if (!__hasProp.call(source, key)) continue;
        val = source[key];
        target[key] = val;
      }
    }
    return target;
  };

  describe("Opentip.Joint", function() {
    describe("constructor()", function() {
      it("should forward to set()", function() {
        sinon.stub(Opentip.Joint.prototype, "set");
        new Opentip.Joint("abc");
        expect(Opentip.Joint.prototype.set.args[0][0]).to.be("abc");
        return Opentip.Joint.prototype.set.restore();
      });
      return it("should accept Pointer objects", function() {
        var p, p2;

        p = new Opentip.Joint("top left");
        expect(p.toString()).to.be("top left");
        p2 = new Opentip.Joint(p);
        expect(p).to.not.be(p2);
        return expect(p2.toString()).to.be("top left");
      });
    });
    describe("set()", function() {
      it("should properly set the positions", function() {
        var p;

        p = new Opentip.Joint;
        p.set("top-left");
        expect(p.toString()).to.eql("top left");
        p.set("top-Right");
        expect(p.toString()).to.eql("top right");
        p.set("BOTTOM left");
        return expect(p.toString()).to.eql("bottom left");
      });
      it("should handle any order of positions", function() {
        var p;

        p = new Opentip.Joint;
        p.set("right bottom");
        expect(p.toString()).to.eql("bottom right");
        p.set("left left middle");
        expect(p.toString()).to.eql("left");
        p.set("left - top");
        return expect(p.toString()).to.eql("top left");
      });
      return it("should add .bottom, .left etc... properties on the position", function() {
        var positions, testCount, testPointers;

        positions = {
          top: false,
          bottom: false,
          middle: false,
          left: false,
          center: false,
          right: false
        };
        testCount = sinon.stub();
        testPointers = function(position, thisPositions) {
          var positionName, shouldBeTrue, _results;

          thisPositions = extend({}, positions, thisPositions);
          _results = [];
          for (positionName in thisPositions) {
            shouldBeTrue = thisPositions[positionName];
            testCount();
            if (shouldBeTrue) {
              _results.push(expect(position[positionName]).to.be.ok());
            } else {
              _results.push(expect(position[positionName]).to.not.be.ok());
            }
          }
          return _results;
        };
        testPointers(new Opentip.Joint("top"), {
          center: true,
          top: true
        });
        testPointers(new Opentip.Joint("top right"), {
          right: true,
          top: true
        });
        testPointers(new Opentip.Joint("right"), {
          right: true,
          middle: true
        });
        testPointers(new Opentip.Joint("bottom right"), {
          right: true,
          bottom: true
        });
        testPointers(new Opentip.Joint("bottom"), {
          center: true,
          bottom: true
        });
        testPointers(new Opentip.Joint("bottom left"), {
          left: true,
          bottom: true
        });
        testPointers(new Opentip.Joint("left"), {
          left: true,
          middle: true
        });
        testPointers(new Opentip.Joint("top left"), {
          left: true,
          top: true
        });
        return expect(testCount.callCount).to.be(6 * 8);
      });
    });
    describe("setHorizontal()", function() {
      return it("should set the horizontal position", function() {
        var p;

        p = new Opentip.Joint("top left");
        expect(p.left).to.be.ok();
        expect(p.top).to.be.ok();
        p.setHorizontal("right");
        expect(p.left).to.not.be.ok();
        expect(p.top).to.be.ok();
        return expect(p.right).to.be.ok();
      });
    });
    describe("setVertical()", function() {
      return it("should set the vertical position", function() {
        var p;

        p = new Opentip.Joint("top left");
        expect(p.top).to.be.ok();
        expect(p.left).to.be.ok();
        p.setVertical("bottom");
        expect(p.top).to.not.be.ok();
        expect(p.left).to.be.ok();
        return expect(p.bottom).to.be.ok();
      });
    });
    return describe("flip()", function() {
      it("should return itself for chaining", function() {
        var p, p2;

        p = new Opentip.Joint("top");
        p2 = p.flip();
        return expect(p).to.be(p2);
      });
      return it("should properly flip the position", function() {
        expect(new Opentip.Joint("top").flip().toString()).to.be("bottom");
        expect(new Opentip.Joint("bottomRight").flip().toString()).to.be("top left");
        expect(new Opentip.Joint("left top").flip().toString()).to.be("bottom right");
        return expect(new Opentip.Joint("bottom").flip().toString()).to.be("top");
      });
    });
  });

}).call(this);

(function() {
  var $, adapters,
    __hasProp = {}.hasOwnProperty;

  $ = jQuery;

  if (Opentip.adapters.component) {
    adapters = ["component"];
  } else {
    adapters = ["native", "ender", "jquery", "prototype"];
  }

  describe("Generic adapter", function() {
    var adapterName, _i, _len, _results;

    _results = [];
    for (_i = 0, _len = adapters.length; _i < _len; _i++) {
      adapterName = adapters[_i];
      _results.push(describe("" + adapterName + " adapter", function() {
        var adapter;

        it("should add itself to Opentip.adapters." + adapterName, function() {
          return expect(Opentip.adapters[adapterName]).to.be.ok();
        });
        adapter = Opentip.adapters[adapterName];
        describe("domReady()", function() {
          return it("should call the callback", function(done) {
            return adapter.domReady(function() {
              return done();
            });
          });
        });
        describe("clone()", function() {
          return it("should create a shallow copy", function() {
            var obj, obj2;

            obj = {
              a: 1,
              b: 2,
              c: {
                d: 3
              }
            };
            obj2 = adapter.clone(obj);
            expect(obj).to.not.equal(obj2);
            expect(obj).to.eql(obj2);
            obj2.a = 10;
            expect(obj).to.not.eql(obj2);
            expect(obj.a).to.equal(1);
            obj2.c.d = 30;
            return expect(obj.c.d).to.equal(30);
          });
        });
        describe("extend()", function() {
          return it("should copy all attributes from sources to target and return the extended object as well", function() {
            var returned, source1, source2, target;

            target = {
              a: 1,
              b: 2,
              c: 3
            };
            source1 = {
              a: 10,
              b: 20
            };
            source2 = {
              a: 100
            };
            returned = adapter.extend(target, source1, source2);
            expect(returned).to.equal(target);
            return expect(target).to.eql({
              a: 100,
              b: 20,
              c: 3
            });
          });
        });
        return describe("DOM", function() {
          describe("tagName()", function() {
            return it("should return the tagName of passed element", function() {
              var element;

              element = document.createElement("div");
              return expect(adapter.tagName(element)).to.equal("DIV");
            });
          });
          describe("wrap()", function() {
            return it("should also handle css selector strings", function() {
              var element, unwrapped, wrapped;

              element = document.createElement("div");
              element.id = "wrap-test";
              document.body.appendChild(element);
              wrapped = adapter.wrap("div#wrap-test");
              unwrapped = adapter.unwrap(wrapped);
              expect(element).to.be(unwrapped);
              return document.body.removeChild(element);
            });
          });
          describe("unwrap()", function() {
            return it("should properly return the unwrapped element", function() {
              var element, unwrapped, unwrapped2, wrapped;

              element = document.createElement("div");
              wrapped = adapter.wrap(element);
              unwrapped = adapter.unwrap(element);
              unwrapped2 = adapter.unwrap(wrapped);
              return expect((element === unwrapped && unwrapped === unwrapped2)).to.be.ok();
            });
          });
          describe("attr()", function() {
            it("should return the attribute of passed element", function() {
              var element;

              element = document.createElement("a");
              element.setAttribute("href", "http://link");
              return expect(adapter.attr(adapter.wrap(element), "href")).to.equal("http://link");
            });
            return it("should set the attribute of passed element", function() {
              var element;

              element = document.createElement("a");
              adapter.attr(element, "class", "test-class");
              adapter.attr(adapter.wrap(element), "href", "http://link");
              expect(adapter.attr(element, "class")).to.equal("test-class");
              return expect(adapter.attr(element, "href")).to.equal("http://link");
            });
          });
          describe("data()", function() {
            it("should set and return arbitrary data for element", function() {
              var element, element2;

              element = document.createElement("div");
              element2 = document.createElement("div");
              adapter.data(element, "test", ["a", "b"]);
              adapter.data(adapter.wrap(element), "someOtherTest", "simple string");
              expect(adapter.data(element, "test")).to.eql(["a", "b"]);
              expect(adapter.data(adapter.wrap(element), "someOtherTest")).to.equal("simple string");
              return expect(adapter.data(element2, "someOtherTest")).to.not.be.ok();
            });
            it("should set empty data element", function() {
              var element;

              element = document.createElement("a");
              adapter.data(element, "test", ["a", "b"]);
              expect(adapter.data(element, "test")).to.eql(["a", "b"]);
              adapter.data(element, "test", null);
              return expect(adapter.data(element, "test")).to.eql(null);
            });
            return it("should return existing data", function() {
              var element, nodeElement;

              nodeElement = $("<div data-ot=\"hello\" data-my-test=\"some string\"></div>");
              element = nodeElement[0];
              expect(adapter.data(element, "ot")).to.equal("hello");
              return expect(adapter.data(element, "myTest")).to.equal("some string");
            });
          });
          describe("addClass()", function() {
            return it("should properly add the class", function() {
              var element, val;

              element = document.createElement("div");
              adapter.addClass(element, "test");
              adapter.addClass(adapter.wrap(element), "test2");
              return expect((function() {
                var _j, _len1, _ref, _results1;

                _ref = element.classList;
                _results1 = [];
                for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                  val = _ref[_j];
                  _results1.push(val);
                }
                return _results1;
              })()).to.eql(["test", "test2"]);
            });
          });
          describe("removeClass()", function() {
            return it("should properly add the class", function() {
              var element, val;

              element = document.createElement("div");
              adapter.addClass(element, "test");
              adapter.addClass(adapter.wrap(element), "test2");
              adapter.removeClass(element, "test2");
              expect((function() {
                var _j, _len1, _ref, _results1;

                _ref = element.classList;
                _results1 = [];
                for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                  val = _ref[_j];
                  _results1.push(val);
                }
                return _results1;
              })()).to.eql(["test"]);
              adapter.removeClass(element, "test");
              return expect((function() {
                var _j, _len1, _ref, _results1;

                _ref = element.classList;
                _results1 = [];
                for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                  val = _ref[_j];
                  _results1.push(val);
                }
                return _results1;
              })()).to.eql([]);
            });
          });
          describe("css()", function() {
            return it("should properly set the style", function() {
              var element;

              element = document.createElement("div");
              adapter.css(element, {
                color: "red"
              });
              adapter.css(adapter.wrap(element), {
                backgroundColor: "green"
              });
              expect(element.style.color).to.be("red");
              return expect(element.style.backgroundColor).to.be("green");
            });
          });
          describe("dimensions()", function() {
            it("should return an object with the correct dimensions", function() {
              var dim, dim2, element;

              element = $("<div style=\"display:block; position: absolute; width: 100px; height: 200px;\"></div>")[0];
              $("body").append(element);
              dim = adapter.dimensions(element);
              dim2 = adapter.dimensions(adapter.wrap(element));
              expect(dim).to.eql(dim2);
              expect(dim).to.eql({
                width: 100,
                height: 200
              });
              return $(element).remove();
            });
            it("should return an object with the correct dimensions including border and padding", function() {
              var dim, element;

              element = $("<div style=\"display:block; position: absolute; width: 100px; height: 200px; padding: 20px; border: 2px solid black;\"></div>")[0];
              $("body").append(element);
              dim = adapter.dimensions(element);
              expect(dim).to.eql({
                width: 144,
                height: 244
              });
              return $(element).remove();
            });
            return it("should return an object with the correct dimensions even if display none", function() {
              var dim, element;

              element = $("<div style=\"display:none; position: absolute; width: 100px; height: 200px;\"></div>")[0];
              $("body").append(element);
              dim = adapter.dimensions(element);
              expect(dim).to.eql({
                width: 100,
                height: 200
              });
              return $(element).remove();
            });
          });
          describe("viewportDimensions()", function() {
            return it("should return the viewportDimensions", function() {
              var dims, origDimensions;

              origDimensions = {
                width: document.documentElement.clientWidth,
                height: document.documentElement.clientHeight
              };
              dims = adapter.viewportDimensions();
              expect(dims).to.eql(origDimensions);
              expect(dims.width).to.be.above(0);
              return expect(dims.height).to.be.above(0);
            });
          });
          describe("scrollOffset()", function() {
            return it("should return the correct scroll offset", function() {
              var origScrollOffset, scrollOffset;

              origScrollOffset = [window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft, window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop];
              scrollOffset = adapter.scrollOffset();
              expect(scrollOffset).to.eql(origScrollOffset);
              expect(scrollOffset).to.be.an(Array);
              return expect(scrollOffset.length).to.be(2);
            });
          });
          describe("find()", function() {
            it("should only return one element", function() {
              var aElement, element;

              element = $("<div><span id=\"a-span\" class=\"a\"></span><div id=\"b-span\" class=\"b\"></div></div>")[0];
              aElement = adapter.find(element, ".a");
              expect(aElement.length === void 0).to.be.ok();
              return expect(aElement.tagName).to.be("SPAN");
            });
            it("should properly retrieve child elements", function() {
              var a, b, element;

              element = $("<div><span id=\"a-span\" class=\"a\"></span><div id=\"b-span\" class=\"b\"></div></div>")[0];
              a = adapter.unwrap(adapter.find(element, ".a"));
              b = adapter.unwrap(adapter.find(adapter.wrap(element), ".b"));
              expect(a.id).to.equal("a-span");
              return expect(b.id).to.equal("b-span");
            });
            return it("should return null if no element", function() {
              var a, element;

              element = $("<div></div>")[0];
              a = adapter.unwrap(adapter.find(element, ".a"));
              return expect(a).to.not.be.ok();
            });
          });
          describe("findAll()", function() {
            it("should properly retrieve child elements", function() {
              var a, b, element;

              element = $("<div><span id=\"a-span\" class=\"a\"></span><span id=\"b-span\" class=\"b\"></span></div>")[0];
              a = adapter.findAll(element, "span");
              b = adapter.findAll(adapter.wrap(element), "span");
              expect(a.length).to.equal(2);
              return expect(b.length).to.equal(2);
            });
            return it("should return empty array if no element", function() {
              var a, b, element;

              element = $("<div></div>")[0];
              a = adapter.findAll(element, "span");
              b = adapter.findAll(adapter.wrap(element), "span");
              expect(a.length).to.be(0);
              return expect(b.length).to.be(0);
            });
          });
          describe("update()", function() {
            it("should escape html if wanted", function() {
              var element;

              element = document.createElement("div");
              adapter.update(element, "abc <div>test</div>", true);
              expect(element.firstChild.textContent).to.be("abc <div>test</div>");
              element = document.createElement("div");
              adapter.update(adapter.wrap(element), "abc <div>test2</div>", true);
              return expect(element.firstChild.textContent).to.be("abc <div>test2</div>");
            });
            it("should not escape html if wanted", function() {
              var element;

              element = document.createElement("div");
              adapter.update(element, "abc<div>test</div>", false);
              expect(element.childNodes.length).to.be(2);
              expect(element.firstChild.textContent).to.be("abc");
              expect(element.childNodes[1].textContent).to.be("test");
              element = document.createElement("div");
              adapter.update(adapter.wrap(element), "abc<div>test</div>", false);
              return expect(element.childNodes.length).to.be(2);
            });
            it("should delete previous content in plain text", function() {
              var element;

              element = document.createElement("div");
              adapter.update(element, "abc", true);
              adapter.update(element, "abc", true);
              expect(element.innerHTML).to.be("abc");
              adapter.update(adapter.wrap(element), "abc", true);
              return expect(element.innerHTML).to.be("abc");
            });
            return it("should delete previous content in HTML", function() {
              var element;

              element = document.createElement("div");
              adapter.update(element, "abc", false);
              adapter.update(element, "abc", false);
              expect(element.innerHTML).to.be("abc");
              adapter.update(adapter.wrap(element), "abc", false);
              return expect(element.innerHTML).to.be("abc");
            });
          });
          describe("append()", function() {
            it("should properly append child to element", function() {
              var child, element;

              element = document.createElement("div");
              child = document.createElement("span");
              adapter.append(element, child);
              expect(element.innerHTML).to.eql("<span></span>");
              element = document.createElement("div");
              child = document.createElement("span");
              adapter.append(adapter.wrap(element), adapter.wrap(child));
              return expect(element.innerHTML).to.eql("<span></span>");
            });
            return it("should properly append child to element when created with adapter", function() {
              var child, element;

              element = adapter.create("<div></div>");
              child = adapter.create("<span></span>");
              adapter.append(element, child);
              element = adapter.unwrap(element);
              child = adapter.unwrap(child);
              expect(element.innerHTML).to.eql("<span></span>");
              element = document.createElement("div");
              child = document.createElement("span");
              adapter.append(adapter.wrap(element), adapter.wrap(child));
              return expect(element.innerHTML).to.eql("<span></span>");
            });
          });
          describe("remove()", function() {
            return it("should completely remove element", function() {
              var element;

              element = document.createElement("div");
              element.className = "testelement99";
              adapter.append(document.body, element);
              expect(adapter.find(document.body, ".testelement99")).to.be.ok();
              adapter.remove(element);
              return expect(adapter.find(document.body, ".testelement99")).to.not.be.ok();
            });
          });
          describe("offset()", function() {
            it("should only return left and top", function() {
              var element, key, offset;

              element = $("<div style=\"display:block; position: absolute; left: 100px; top: 200px;\"></div>")[0];
              $("body").append(element);
              offset = adapter.offset(element);
              for (key in offset) {
                if (!__hasProp.call(offset, key)) continue;
                if (key !== "left" && key !== "top") {
                  throw new Error("Other keys returned");
                }
              }
              return $(element).remove();
            });
            return it("should properly return the offset position", function() {
              var element, offset, offset2;

              element = $("<div style=\"display:block; position: absolute; left: 100px; top: 200px;\"></div>")[0];
              $("body").append(element);
              offset = adapter.offset(element);
              offset2 = adapter.offset(adapter.wrap(element));
              expect(offset).to.eql(offset2);
              expect(offset).to.eql({
                left: 100,
                top: 200
              });
              return $(element).remove();
            });
          });
          describe("observe()", function() {
            it("should attach an event listener", function(done) {
              var element;

              element = document.createElement("a");
              adapter.observe(element, "click", function() {
                return done();
              });
              return Test.clickElement(element);
            });
            it("should allow to attach an event to window", function() {
              return adapter.observe(window, "resize", function() {});
            });
            return it("should attach an event listener to wrapped", function(done) {
              var element;

              element = document.createElement("a");
              adapter.observe(adapter.wrap(element), "click", function() {
                return done();
              });
              return Test.clickElement(element);
            });
          });
          describe("stopObserving()", function() {
            it("should remove event listener", function() {
              var element, listener;

              element = document.createElement("a");
              listener = sinon.stub();
              adapter.observe(element, "click", listener);
              Test.clickElement(element);
              Test.clickElement(element);
              expect(listener.callCount).to.equal(2);
              adapter.stopObserving(element, "click", listener);
              Test.clickElement(element);
              return expect(listener.callCount).to.equal(2);
            });
            it("should allow to remove event listener on window", function() {
              var listener;

              listener = sinon.stub();
              adapter.observe(window, "resize", listener);
              return adapter.stopObserving(window, "resize", listener);
            });
            return it("should remove event listener from wrapped", function() {
              var element, listener;

              element = document.createElement("a");
              listener = sinon.stub();
              adapter.observe(element, "click", listener);
              Test.clickElement(element);
              Test.clickElement(element);
              expect(listener.callCount).to.equal(2);
              adapter.stopObserving(adapter.wrap(element), "click", listener);
              Test.clickElement(element);
              return expect(listener.callCount).to.equal(2);
            });
          });
          return describe("ajax()", function() {
            var server;

            server = null;
            before(function() {
              server = sinon.fakeServer.create();
              server.respondWith("GET", "/ajax-test", "success get");
              server.respondWith("POST", "/ajax-test", "success post");
              server.respondWith("GET", "/ajax-test404", [
                404, {
                  "Content-Type": "text/plain"
                }, "error"
              ]);
              return server.autoRespond = true;
            });
            after(function() {
              return server.restore();
            });
            it("should throw an exception if no url provided", function() {
              var e;

              try {
                adapter.ajax({});
                return expect(true).to.be(false);
              } catch (_error) {
                e = _error;
                return expect(e.message).to.be("No url provided");
              }
            });
            it("should properly download the content with get", function(done) {
              var success;

              success = sinon.stub();
              return adapter.ajax({
                url: "/ajax-test",
                method: "GET",
                onSuccess: function(response) {
                  expect(response).to.be("success get");
                  return success();
                },
                onError: function(error) {
                  return done(error);
                },
                onComplete: function() {
                  expect(success.callCount).to.be(1);
                  return done();
                }
              });
            });
            it("should properly download the content with post", function(done) {
              var success;

              success = sinon.stub();
              return adapter.ajax({
                url: "/ajax-test",
                method: "post",
                onSuccess: function(response) {
                  expect(response).to.be("success post");
                  return success();
                },
                onError: function(error) {
                  return done(error);
                },
                onComplete: function() {
                  expect(success.callCount).to.be(1);
                  return done();
                }
              });
            });
            return it("should properly call onError if error", function(done) {
              var errorStub;

              errorStub = sinon.stub();
              return adapter.ajax({
                url: "/ajax-test404",
                method: "GET",
                onSuccess: function(response) {
                  return done("Shouldn't have called onSuccess");
                },
                onError: function(error) {
                  expect(error).to.be("Server responded with status 404");
                  return errorStub();
                },
                onComplete: function() {
                  expect(errorStub.callCount).to.be(1);
                  return done();
                }
              });
            });
          });
        });
      }));
    }
    return _results;
  });

}).call(this);

(function() {
  if (Opentip.adapters.component == null) {
    describe("Native adapter", function() {
      var adapter;

      adapter = Opentip.adapter;
      return describe("DOM", function() {
        describe("create()", function() {
          it("should properly create DOM elements from string", function() {
            var elements;

            elements = adapter.create("<div class=\"test\"><span>HI</span></div>");
            expect(elements).to.be.an("object");
            expect(elements.length).to.equal(1);
            return expect(elements[0].className).to.equal("test");
          });
          return it("the created elements should be wrapped", function() {
            var elements, wrapped;

            elements = adapter.create("<div class=\"test\"><span>HI</span></div>");
            wrapped = adapter.wrap(elements);
            return expect(elements).to.equal(wrapped);
          });
        });
        return describe("wrap()", function() {
          it("should wrap the element in an array", function() {
            var element, wrapped;

            element = document.createElement("div");
            wrapped = adapter.wrap(element);
            return expect(element).to.equal(wrapped[0]);
          });
          return it("should properly wrap nodelists", function() {
            var wrapped;

            wrapped = adapter.wrap(document.body.childNodes);
            return expect(wrapped).to.not.be.a(NodeList);
          });
        });
      });
    });
  }

}).call(this);

(function() {
  var $;

  if (Opentip.adapters.component == null) {
    $ = jQuery;
    describe("Ender adapter", function() {
      var adapter;

      adapter = Opentip.adapter;
      return describe("DOM", function() {
        describe("create()", function() {
          return it("should properly create DOM elements from string", function() {
            var elements;

            elements = adapter.create("<div class=\"test\"><span>HI</span></div>");
            expect(elements).to.be.an("object");
            expect(elements.length).to.equal(1);
            return expect(elements[0].className).to.equal("test");
          });
        });
        describe("wrap()", function() {
          return it("should return a bonzo element", function() {
            var element, wrapped;

            element = document.createElement("div");
            wrapped = adapter.wrap(element);
            expect(element).to.not.equal(wrapped);
            return expect(element).to.equal(adapter.unwrap(wrapped));
          });
        });
        describe("tagName()", function() {
          return it("should return the tagName of passed ender element", function() {
            var element;

            element = $("div")[0];
            return expect(adapter.tagName(element)).to.equal("DIV");
          });
        });
        describe("attr()", function() {
          return it("should return the attribute of passed ender element", function() {
            var element;

            element = $("<a href=\"http://link\"></a>")[0];
            return expect(adapter.attr(element, "href")).to.equal("http://link");
          });
        });
        return describe("observe()", function() {
          return it("should observe given event on ender element", function(done) {
            var element;

            element = $("<a>link</a>")[0];
            adapter.observe(element, "click", function() {
              return done();
            });
            return Test.clickElement(element);
          });
        });
      });
    });
  }

}).call(this);
