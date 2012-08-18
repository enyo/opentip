
$ = ender

describe "Native adapter", ->
  adapter = Opentip.adapters.native

  describe "DOM", ->
    describe "create()", ->
      it "should properly create DOM elements from string", ->
        elements = adapter.create """<div class="test"><span>HI</span></div>"""
        expect(elements).to.be.an "object"
        expect(elements.length).to.equal 1
        expect(elements[0].className).to.equal "test"
      it "the created elements should be wrapped", ->
        elements = adapter.create """<div class="test"><span>HI</span></div>"""
        wrapped = adapter.wrap elements
        expect(elements).to.equal wrapped

    describe "wrap()", ->
      it "should wrap the element in an array", ->
        element = document.createElement "div"
        wrapped = adapter.wrap element
        expect(element).to.equal wrapped[0]

    describe "observe()", ->
      it "should handle stopPropagation"


