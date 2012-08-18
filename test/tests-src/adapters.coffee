
$ = ender

adapters = [
  "native"
  "ender"
]

describe "Generic adapter", ->
  for adapterName in adapters
    describe "#{adapterName} adapter", ->

      it "should add itself to Opentip.adapters.#{adapterName}", ->
        expect(Opentip.adapters[adapterName]).to.be.ok()

      adapter = Opentip.adapters[adapterName]

      describe "domReady()", ->
        it "should call the callback", (done) ->
          adapter.domReady done

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

      describe "extend()", ->
        it "should copy all attributes from sources to target", ->
          target =
            a: 1
            b: 2
            c: 3
          source1 =
            a: 10
            b: 20
          source2 =
            a: 100

          adapter.extend target, source1, source2
          expect(target).to.eql
            a: 100
            b: 20
            c: 3

      describe "DOM", ->
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
          it "should set the attribute of passed element", ->
            element = document.createElement "a"
            adapter.attr element, "class", "test-class"
            adapter.attr element, "href", "http://link"
            expect(adapter.attr element, "class").to.equal "test-class"
            expect(adapter.attr element, "href").to.equal "http://link"

        describe "addClass()", ->
          it "should properly add the class", ->
            element = document.createElement "div"
            adapter.addClass element, "test"
            adapter.addClass element, "test2"
            expect(val for val in element.classList).to.eql [ "test", "test2" ]

        describe "removeClass()", ->
          it "should properly add the class", ->
            element = document.createElement "div"
            adapter.addClass element, "test"
            adapter.addClass element, "test2"
            adapter.removeClass element, "test2"
            expect(val for val in element.classList).to.eql [ "test" ]
            adapter.removeClass element, "test"
            expect(val for val in element.classList).to.eql [ ]

        describe "observe()", ->
          it "should attach an event listener", (done) ->
            element = document.createElement "a"
            adapter.observe element, "click", -> done()
            element.click()

        describe "stopObserving()", ->
          it "should remove event listener", ->
            element = document.createElement "a"
            listener = sinon.stub()
            adapter.observe element, "click", listener
            element.click()
            element.click()
            expect(listener.callCount).to.equal 2
            adapter.stopObserving element, "click", listener
            element.click()
            expect(listener.callCount).to.equal 2 # Shouldn't have changed

