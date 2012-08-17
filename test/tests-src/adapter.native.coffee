
$ = ender

describe "Native adapter", ->
  it "should add itself to Opentip.adapters.native", ->
    expect(Opentip.adapters.native).to.be.ok()

  adapter = Opentip.adapters.native

  describe "domReady()", ->
    it "should call the callback", (done) ->
      adapter.domReady done

  describe "DOM", ->
    describe "clone()", ->
      it "should create a shallow copy", ->
        obj =
          a: 1
          b: 2
          c:
            d: 3

        obj2 = adapter.clone obj

        expect(obj).to.not.equal obj2
        expect(obj).to.eql obj2
        obj2.a = 10
        expect(obj).to.not.eql obj2
        expect(obj.a).to.equal 1
        obj2.c.d = 30
        expect(obj.c.d).to.equal 30 # Shallow copy

    describe "create()", ->
      it "should properly create DOM elements from string", ->
        elements = adapter.create """<div class="test"><span>HI</span></div>"""
        expect(elements).to.be.an "object"
        expect(elements.length).to.equal 1
        expect(elements[0].className).to.equal "test"

    describe "wrap()", ->
      it "should just return the element", ->
        element = document.createElement "div"
        element2 = adapter.wrap element
        expect(element).to.equal element2

    describe "tagName()", ->
      it "should return the tagName of passed element", ->
        element = document.createElement "div"
        expect(adapter.tagName element).to.equal "DIV"

    describe "attr()", ->
      it "should return the attribute of passed element", ->
        element = document.createElement "a"
        element.setAttribute "class", "test-class"
        element.setAttribute "href", "http://link"
        expect(adapter.attr element, "class").to.equal "test-class"
        expect(adapter.attr element, "href").to.equal "http://link"



