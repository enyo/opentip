
$ = ender

describe "Ender adapter", ->
  adapter = Opentip.adapters.ender

  describe "DOM", ->
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



