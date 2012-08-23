
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

        describe "unwrap()", ->
          it "should properly return the unwrapped element", ->
            element = document.createElement "div"
            wrapped = adapter.wrap element
            unwrapped = adapter.unwrap element
            unwrapped2 = adapter.unwrap wrapped
            expect(element == unwrapped == unwrapped2).to.be.ok()

        describe "attr()", ->
          it "should return the attribute of passed element", ->
            element = document.createElement "a"
            element.setAttribute "class", "test-class"
            element.setAttribute "href", "http://link"
            expect(adapter.attr element, "class").to.equal "test-class"
            expect(adapter.attr adapter.wrap(element), "href").to.equal "http://link" # Testing with wrapped as well
          it "should set the attribute of passed element", ->
            element = document.createElement "a"
            adapter.attr element, "class", "test-class"
            adapter.attr adapter.wrap(element), "href", "http://link" # Testing with wrapped as well
            expect(adapter.attr element, "class").to.equal "test-class"
            expect(adapter.attr element, "href").to.equal "http://link"

        describe "addClass()", ->
          it "should properly add the class", ->
            element = document.createElement "div"
            adapter.addClass element, "test"
            adapter.addClass adapter.wrap(element), "test2" # Testing with wrapped as well
            expect(val for val in element.classList).to.eql [ "test", "test2" ]

        describe "removeClass()", ->
          it "should properly add the class", ->
            element = document.createElement "div"
            adapter.addClass element, "test"
            adapter.addClass adapter.wrap(element), "test2" # Testing with wrapped as well
            adapter.removeClass element, "test2"
            expect(val for val in element.classList).to.eql [ "test" ]
            adapter.removeClass element, "test"
            expect(val for val in element.classList).to.eql [ ]

        describe "css()", ->
          it "should properly set the style", ->
            element = document.createElement "div"
            adapter.css element, color: "red"
            adapter.css adapter.wrap(element), backgroundColor: "green" # Testing with wrapped as well
            expect(element.style.color).to.be "red"
            expect(element.style.backgroundColor).to.be "green"

        describe "dimensions()", ->
          it "should return an object with the correct dimensions", ->
            element = $("""<div style="display:block; position: absolute; width: 100px; height: 200px;"></div>""").get 0
            $("body").append element
            dim = adapter.dimensions element
            dim2 = adapter.dimensions adapter.wrap element # Testing with wrapped as well
            expect(dim).to.eql dim2
            expect(dim).to.eql width: 100, height: 200
            $(element).remove()


        describe "find()", ->
          it "should properly retrieve child elements", ->
            element = $("""<div><span id="a-span" class="a"></span><div id="b-span" class="b"></div></div>""").get(0)
            a = adapter.unwrap adapter.find element, ".a"
            b = adapter.unwrap adapter.find adapter.wrap(element), ".b" # Testing with wrapped as well
            expect(a.id).to.equal "a-span"
            expect(b.id).to.equal "b-span"
          it "should return null if no element", ->
            element = $("""<div></div>""").get(0)
            a = adapter.unwrap adapter.find element, ".a"
            expect(a).to.be null

        describe "findAll()", ->
          it "should properly retrieve child elements", ->
            element = $("""<div><span id="a-span" class="a"></span><span id="b-span" class="b"></span></div>""").get(0)
            a = adapter.findAll element, "span"
            b = adapter.findAll adapter.wrap(element), "span" # Testing with wrapped as well
            expect(a.length).to.equal 2
            expect(b.length).to.equal 2
          it "should return empty array if no element", ->
            element = $("""<div></div>""").get(0)
            a = adapter.findAll element, "span"
            b = adapter.findAll adapter.wrap(element), "span" # Testing with wrapped as well
            expect(a.length).to.be 0
            expect(b.length).to.be 0

        describe "update()", ->
          it "should escape html if wanted", ->
            element = document.createElement "div"
            adapter.update element, "abc <div>test</div>", yes
            expect(element.firstChild.textContent).to.be "abc <div>test</div>"
            element = document.createElement "div"
            adapter.update adapter.wrap(element), "abc <div>test2</div>", yes # Testing with wrapped as well
            expect(element.firstChild.textContent).to.be "abc <div>test2</div>"
          it "should not escape html if wanted", ->
            element = document.createElement "div"
            adapter.update element, "abc<div>test</div>", no
            expect(element.childNodes.length).to.be 2
            expect(element.firstChild.textContent).to.be "abc"
            expect(element.childNodes[1].textContent).to.be "test"
            element = document.createElement "div"
            adapter.update adapter.wrap(element), "abc<div>test</div>", no # Testing with wrapped as well
            expect(element.childNodes.length).to.be 2
          it "should delete previous content in plain text", ->
            element = document.createElement "div"
            adapter.update element, "abc", yes
            adapter.update element, "abc", yes
            expect(element.innerHTML).to.be "abc"
            adapter.update adapter.wrap(element), "abc", yes # Testing with wrapped as well
            expect(element.innerHTML).to.be "abc"
          it "should delete previous content in HTML", ->
            element = document.createElement "div"
            adapter.update element, "abc", no
            adapter.update element, "abc", no
            expect(element.innerHTML).to.be "abc"
            adapter.update adapter.wrap(element), "abc", no # Testing with wrapped as well
            expect(element.innerHTML).to.be "abc"

        describe "append()", ->
          it "should properly append child to element", ->
            element = document.createElement "div"
            child = document.createElement "span"
            adapter.append element, child
            expect(element.innerHTML).to.eql "<span></span>"
            # Testing with wrapped as well
            element = document.createElement "div"
            child = document.createElement "span"
            adapter.append adapter.wrap(element), adapter.wrap(child)
            expect(element.innerHTML).to.eql "<span></span>"

        describe "offset()", ->
          it "should only return left and top", ->
            element = $("""<div style="display:block; position: absolute; left: 100px; top: 200px;"></div>""").get 0
            $("body").append element
            offset = adapter.offset element
            for own key of offset
              if key isnt "left" and key isnt "top"
                throw new Error "Other keys returned"
            $(element).remove()
          it "should properly return the offset position", ->
            element = $("""<div style="display:block; position: absolute; left: 100px; top: 200px;"></div>""").get 0
            $("body").append element
            offset = adapter.offset element
            offset2 = adapter.offset adapter.wrap element # Testing with wrapped as well
            expect(offset).to.eql offset2
            expect(offset).to.eql left: 100, top: 200
            $(element).remove()

        describe "observe()", ->
          it "should attach an event listener", (done) ->
            element = document.createElement "a"
            adapter.observe element, "click", -> done()
            element.click()
          it "should attach an event listener to wrapped", (done) ->
            element = document.createElement "a"
            adapter.observe adapter.wrap(element), "click", -> done()
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

          it "should remove event listener from wrapped", ->
            element = document.createElement "a"
            listener = sinon.stub()
            adapter.observe element, "click", listener
            element.click()
            element.click()
            expect(listener.callCount).to.equal 2
            adapter.stopObserving adapter.wrap(element), "click", listener
            element.click()
            expect(listener.callCount).to.equal 2 # Shouldn't have changed

