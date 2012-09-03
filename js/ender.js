/*!
  * =============================================================
  * Ender: open module JavaScript framework (https://ender.no.de)
  * Build: ender build bean bonzo domready qwery opentip reqwest
  * =============================================================
  */

/*!
  * Ender: open module JavaScript framework (client-lib)
  * copyright Dustin Diaz & Jacob Thornton 2011-2012 (@ded @fat)
  * http://ender.no.de
  * License MIT
  */
(function (context) {

  // a global object for node.js module compatiblity
  // ============================================

  context['global'] = context

  // Implements simple module system
  // losely based on CommonJS Modules spec v1.1.1
  // ============================================

  var modules = {}
    , old = context['$']
    , oldEnder = context['ender']
    , oldRequire = context['require']
    , oldProvide = context['provide']

  function require (identifier) {
    // modules can be required from ender's build system, or found on the window
    var module = modules['$' + identifier] || window[identifier]
    if (!module) throw new Error("Ender Error: Requested module '" + identifier + "' has not been defined.")
    return module
  }

  function provide (name, what) {
    return (modules['$' + name] = what)
  }

  context['provide'] = provide
  context['require'] = require

  function aug(o, o2) {
    for (var k in o2) k != 'noConflict' && k != '_VERSION' && (o[k] = o2[k])
    return o
  }

  /**
   * main Ender return object
   * @constructor
   * @param {Array|Node|string} s a CSS selector or DOM node(s)
   * @param {Array.|Node} r a root node(s)
   */
  function Ender(s, r) {
    var elements
      , i

    this.selector = s
    // string || node || nodelist || window
    if (typeof s == 'undefined') {
      elements = []
      this.selector = ''
    } else if (typeof s == 'string' || s.nodeName || (s.length && 'item' in s) || s == window) {
      elements = ender._select(s, r)
    } else {
      elements = isFinite(s.length) ? s : [s]
    }
    this.length = elements.length
    for (i = this.length; i--;) this[i] = elements[i]
  }

  /**
   * @param {function(el, i, inst)} fn
   * @param {Object} opt_scope
   * @returns {Ender}
   */
  Ender.prototype['forEach'] = function (fn, opt_scope) {
    var i, l
    // opt out of native forEach so we can intentionally call our own scope
    // defaulting to the current item and be able to return self
    for (i = 0, l = this.length; i < l; ++i) i in this && fn.call(opt_scope || this[i], this[i], i, this)
    // return self for chaining
    return this
  }

  Ender.prototype.$ = ender // handy reference to self


  function ender(s, r) {
    return new Ender(s, r)
  }

  ender['_VERSION'] = '0.4.3-dev'

  ender.fn = Ender.prototype // for easy compat to jQuery plugins

  ender.ender = function (o, chain) {
    aug(chain ? Ender.prototype : ender, o)
  }

  ender._select = function (s, r) {
    if (typeof s == 'string') return (r || document).querySelectorAll(s)
    if (s.nodeName) return [s]
    return s
  }


  // use callback to receive Ender's require & provide and remove them from global
  ender.noConflict = function (callback) {
    context['$'] = old
    if (callback) {
      context['provide'] = oldProvide
      context['require'] = oldRequire
      context['ender'] = oldEnder
      if (typeof callback == 'function') callback(require, provide, this)
    }
    return this
  }

  if (typeof module !== 'undefined' && module.exports) module.exports = ender
  // use subscript notation as extern for Closure compilation
  context['ender'] = context['$'] = ender

}(this));

(function () {

  var module = { exports: {} }, exports = module.exports;

  /*!
    * bean.js - copyright Jacob Thornton 2011
    * https://github.com/fat/bean
    * MIT License
    * special thanks to:
    * dean edwards: http://dean.edwards.name/
    * dperini: https://github.com/dperini/nwevents
    * the entire mootools team: github.com/mootools/mootools-core
    */
  !function (name, context, definition) {
    if (typeof module !== 'undefined') module.exports = definition(name, context);
    else if (typeof define === 'function' && typeof define.amd  === 'object') define(definition);
    else context[name] = definition(name, context);
  }('bean', this, function (name, context) {
    var win = window
      , old = context[name]
      , overOut = /over|out/
      , namespaceRegex = /[^\.]*(?=\..*)\.|.*/
      , nameRegex = /\..*/
      , addEvent = 'addEventListener'
      , attachEvent = 'attachEvent'
      , removeEvent = 'removeEventListener'
      , detachEvent = 'detachEvent'
      , ownerDocument = 'ownerDocument'
      , targetS = 'target'
      , qSA = 'querySelectorAll'
      , doc = document || {}
      , root = doc.documentElement || {}
      , W3C_MODEL = root[addEvent]
      , eventSupport = W3C_MODEL ? addEvent : attachEvent
      , slice = Array.prototype.slice
      , mouseTypeRegex = /click|mouse(?!(.*wheel|scroll))|menu|drag|drop/i
      , mouseWheelTypeRegex = /mouse.*(wheel|scroll)/i
      , textTypeRegex = /^text/i
      , touchTypeRegex = /^touch|^gesture/i
      , ONE = {} // singleton for quick matching making add() do one()
  
      , nativeEvents = (function (hash, events, i) {
          for (i = 0; i < events.length; i++)
            hash[events[i]] = 1
          return hash
        }({}, (
            'click dblclick mouseup mousedown contextmenu ' +                  // mouse buttons
            'mousewheel mousemultiwheel DOMMouseScroll ' +                     // mouse wheel
            'mouseover mouseout mousemove selectstart selectend ' +            // mouse movement
            'keydown keypress keyup ' +                                        // keyboard
            'orientationchange ' +                                             // mobile
            'focus blur change reset select submit ' +                         // form elements
            'load unload beforeunload resize move DOMContentLoaded '+          // window
            'readystatechange message ' +                                      // window
            'error abort scroll ' +                                            // misc
            (W3C_MODEL ? // element.fireEvent('onXYZ'... is not forgiving if we try to fire an event
                         // that doesn't actually exist, so make sure we only do these on newer browsers
              'show ' +                                                          // mouse buttons
              'input invalid ' +                                                 // form elements
              'touchstart touchmove touchend touchcancel ' +                     // touch
              'gesturestart gesturechange gestureend ' +                         // gesture
              'readystatechange pageshow pagehide popstate ' +                   // window
              'hashchange offline online ' +                                     // window
              'afterprint beforeprint ' +                                        // printing
              'dragstart dragenter dragover dragleave drag drop dragend ' +      // dnd
              'loadstart progress suspend emptied stalled loadmetadata ' +       // media
              'loadeddata canplay canplaythrough playing waiting seeking ' +     // media
              'seeked ended durationchange timeupdate play pause ratechange ' +  // media
              'volumechange cuechange ' +                                        // media
              'checking noupdate downloading cached updateready obsolete ' +     // appcache
              '' : '')
          ).split(' ')
        ))
  
      , customEvents = (function () {
          var cdp = 'compareDocumentPosition'
            , isAncestor = cdp in root
                ? function (element, container) {
                    return container[cdp] && (container[cdp](element) & 16) === 16
                  }
                : 'contains' in root
                  ? function (element, container) {
                      container = container.nodeType === 9 || container === window ? root : container
                      return container !== element && container.contains(element)
                    }
                  : function (element, container) {
                      while (element = element.parentNode) if (element === container) return 1
                      return 0
                    }
  
          function check(event) {
            var related = event.relatedTarget
            return !related
              ? related === null
              : (related !== this && related.prefix !== 'xul' && !/document/.test(this.toString()) && !isAncestor(related, this))
          }
  
          return {
              mouseenter: { base: 'mouseover', condition: check }
            , mouseleave: { base: 'mouseout', condition: check }
            , mousewheel: { base: /Firefox/.test(navigator.userAgent) ? 'DOMMouseScroll' : 'mousewheel' }
          }
        }())
  
      , fixEvent = (function () {
          var commonProps = 'altKey attrChange attrName bubbles cancelable ctrlKey currentTarget detail eventPhase getModifierState isTrusted metaKey relatedNode relatedTarget shiftKey srcElement target timeStamp type view which'.split(' ')
            , mouseProps = commonProps.concat('button buttons clientX clientY dataTransfer fromElement offsetX offsetY pageX pageY screenX screenY toElement'.split(' '))
            , mouseWheelProps = mouseProps.concat('wheelDelta wheelDeltaX wheelDeltaY wheelDeltaZ axis'.split(' ')) // 'axis' is FF specific
            , keyProps = commonProps.concat('char charCode key keyCode keyIdentifier keyLocation'.split(' '))
            , textProps = commonProps.concat(['data'])
            , touchProps = commonProps.concat('touches targetTouches changedTouches scale rotation'.split(' '))
            , messageProps = commonProps.concat(['data', 'origin', 'source'])
            , preventDefault = 'preventDefault'
            , createPreventDefault = function (event) {
                return function () {
                  if (event[preventDefault])
                    event[preventDefault]()
                  else
                    event.returnValue = false
                }
              }
            , stopPropagation = 'stopPropagation'
            , createStopPropagation = function (event) {
                return function () {
                  if (event[stopPropagation])
                    event[stopPropagation]()
                  else
                    event.cancelBubble = true
                }
              }
            , createStop = function (synEvent) {
                return function () {
                  synEvent[preventDefault]()
                  synEvent[stopPropagation]()
                  synEvent.stopped = true
                }
              }
            , copyProps = function (event, result, props) {
                var i, p
                for (i = props.length; i--;) {
                  p = props[i]
                  if (!(p in result) && p in event) result[p] = event[p]
                }
              }
  
          return function (event, isNative) {
            var result = { originalEvent: event, isNative: isNative }
            if (!event)
              return result
  
            var props
              , type = event.type
              , target = event[targetS] || event.srcElement
  
            result[preventDefault] = createPreventDefault(event)
            result[stopPropagation] = createStopPropagation(event)
            result.stop = createStop(result)
            result[targetS] = target && target.nodeType === 3 ? target.parentNode : target
  
            if (isNative) { // we only need basic augmentation on custom events, the rest is too expensive
              if (type.indexOf('key') !== -1) {
                props = keyProps
                result.keyCode = event.keyCode || event.which
              } else if (mouseTypeRegex.test(type)) {
                props = mouseProps
                result.rightClick = event.which === 3 || event.button === 2
                result.pos = { x: 0, y: 0 }
                if (event.pageX || event.pageY) {
                  result.clientX = event.pageX
                  result.clientY = event.pageY
                } else if (event.clientX || event.clientY) {
                  result.clientX = event.clientX + doc.body.scrollLeft + root.scrollLeft
                  result.clientY = event.clientY + doc.body.scrollTop + root.scrollTop
                }
                if (overOut.test(type))
                  result.relatedTarget = event.relatedTarget || event[(type === 'mouseover' ? 'from' : 'to') + 'Element']
              } else if (touchTypeRegex.test(type)) {
                props = touchProps
              } else if (mouseWheelTypeRegex.test(type)) {
                props = mouseWheelProps
              } else if (textTypeRegex.test(type)) {
                props = textProps
              } else if (type === 'message') {
                props = messageProps
              }
              copyProps(event, result, props || commonProps)
            }
            return result
          }
        }())
  
        // if we're in old IE we can't do onpropertychange on doc or win so we use doc.documentElement for both
      , targetElement = function (element, isNative) {
          return !W3C_MODEL && !isNative && (element === doc || element === win) ? root : element
        }
  
        // we use one of these per listener, of any type
      , RegEntry = (function () {
          function entry(element, type, handler, original, namespaces) {
            var isNative = this.isNative = nativeEvents[type] && element[eventSupport]
            this.element = element
            this.type = type
            this.handler = handler
            this.original = original
            this.namespaces = namespaces
            this.custom = customEvents[type]
            this.eventType = W3C_MODEL || isNative ? type : 'propertychange'
            this.customType = !W3C_MODEL && !isNative && type
            this[targetS] = targetElement(element, isNative)
            this[eventSupport] = this[targetS][eventSupport]
          }
  
          entry.prototype = {
              // given a list of namespaces, is our entry in any of them?
              inNamespaces: function (checkNamespaces) {
                var i, j
                if (!checkNamespaces)
                  return true
                if (!this.namespaces)
                  return false
                for (i = checkNamespaces.length; i--;) {
                  for (j = this.namespaces.length; j--;) {
                    if (checkNamespaces[i] === this.namespaces[j])
                      return true
                  }
                }
                return false
              }
  
              // match by element, original fn (opt), handler fn (opt)
            , matches: function (checkElement, checkOriginal, checkHandler) {
                return this.element === checkElement &&
                  (!checkOriginal || this.original === checkOriginal) &&
                  (!checkHandler || this.handler === checkHandler)
              }
          }
  
          return entry
        }())
  
      , registry = (function () {
          // our map stores arrays by event type, just because it's better than storing
          // everything in a single array. uses '$' as a prefix for the keys for safety
          var map = {}
  
            // generic functional search of our registry for matching listeners,
            // `fn` returns false to break out of the loop
            , forAll = function (element, type, original, handler, fn) {
                if (!type || type === '*') {
                  // search the whole registry
                  for (var t in map) {
                    if (t.charAt(0) === '$')
                      forAll(element, t.substr(1), original, handler, fn)
                  }
                } else {
                  var i = 0, l, list = map['$' + type], all = element === '*'
                  if (!list)
                    return
                  for (l = list.length; i < l; i++) {
                    if (all || list[i].matches(element, original, handler))
                      if (!fn(list[i], list, i, type))
                        return
                  }
                }
              }
  
            , has = function (element, type, original) {
                // we're not using forAll here simply because it's a bit slower and this
                // needs to be fast
                var i, list = map['$' + type]
                if (list) {
                  for (i = list.length; i--;) {
                    if (list[i].matches(element, original, null))
                      return true
                  }
                }
                return false
              }
  
            , get = function (element, type, original) {
                var entries = []
                forAll(element, type, original, null, function (entry) { return entries.push(entry) })
                return entries
              }
  
            , put = function (entry) {
                (map['$' + entry.type] || (map['$' + entry.type] = [])).push(entry)
                return entry
              }
  
            , del = function (entry) {
                forAll(entry.element, entry.type, null, entry.handler, function (entry, list, i) {
                  list.splice(i, 1)
                  if (list.length === 0)
                    delete map['$' + entry.type]
                  return false
                })
              }
  
              // dump all entries, used for onunload
            , entries = function () {
                var t, entries = []
                for (t in map) {
                  if (t.charAt(0) === '$')
                    entries = entries.concat(map[t])
                }
                return entries
              }
  
          return { has: has, get: get, put: put, del: del, entries: entries }
        }())
  
      , selectorEngine = doc[qSA]
          ? function (s, r) {
              return r[qSA](s)
            }
          : function () {
              throw new Error('Bean: No selector engine installed') // eeek
            }
  
      , setSelectorEngine = function (e) {
          selectorEngine = e
        }
  
        // add and remove listeners to DOM elements
      , listener = W3C_MODEL ? function (element, type, fn, add) {
          element[add ? addEvent : removeEvent](type, fn, false)
        } : function (element, type, fn, add, custom) {
          if (custom && add && element['_on' + custom] === null)
            element['_on' + custom] = 0
          element[add ? attachEvent : detachEvent]('on' + type, fn)
        }
  
      , nativeHandler = function (element, fn, args) {
          var beanDel = fn.__beanDel
            , handler = function (event) {
            event = fixEvent(event || ((this[ownerDocument] || this.document || this).parentWindow || win).event, true)
            if (beanDel) // delegated event, fix the fix
              event.currentTarget = beanDel.ft(event[targetS], element)
            return fn.apply(element, [event].concat(args))
          }
          handler.__beanDel = beanDel
          return handler
        }
  
      , customHandler = function (element, fn, type, condition, args, isNative) {
          var beanDel = fn.__beanDel
            , handler = function (event) {
            var target = beanDel ? beanDel.ft(event[targetS], element) : this // deleated event
            if (condition ? condition.apply(target, arguments) : W3C_MODEL ? true : event && event.propertyName === '_on' + type || !event) {
              if (event) {
                event = fixEvent(event || ((this[ownerDocument] || this.document || this).parentWindow || win).event, isNative)
                event.currentTarget = target
              }
              fn.apply(element, event && (!args || args.length === 0) ? arguments : slice.call(arguments, event ? 0 : 1).concat(args))
            }
          }
          handler.__beanDel = beanDel
          return handler
        }
  
      , once = function (rm, element, type, fn, originalFn) {
          // wrap the handler in a handler that does a remove as well
          return function () {
            rm(element, type, originalFn)
            fn.apply(this, arguments)
          }
        }
  
      , removeListener = function (element, orgType, handler, namespaces) {
          var i, l, entry
            , type = (orgType && orgType.replace(nameRegex, ''))
            , handlers = registry.get(element, type, handler)
  
          for (i = 0, l = handlers.length; i < l; i++) {
            if (handlers[i].inNamespaces(namespaces)) {
              if ((entry = handlers[i])[eventSupport])
                listener(entry[targetS], entry.eventType, entry.handler, false, entry.type)
              // TODO: this is problematic, we have a registry.get() and registry.del() that
              // both do registry searches so we waste cycles doing this. Needs to be rolled into
              // a single registry.forAll(fn) that removes while finding, but the catch is that
              // we'll be splicing the arrays that we're iterating over. Needs extra tests to
              // make sure we don't screw it up. @rvagg
              registry.del(entry)
            }
          }
        }
  
      , addListener = function (element, orgType, fn, originalFn, args) {
          var entry
            , type = orgType.replace(nameRegex, '')
            , namespaces = orgType.replace(namespaceRegex, '').split('.')
  
          if (registry.has(element, type, fn))
            return element // no dupe
          if (type === 'unload')
            fn = once(removeListener, element, type, fn, originalFn) // self clean-up
          if (customEvents[type]) {
            if (customEvents[type].condition)
              fn = customHandler(element, fn, type, customEvents[type].condition, args, true)
            type = customEvents[type].base || type
          }
          entry = registry.put(new RegEntry(element, type, fn, originalFn, namespaces[0] && namespaces))
          entry.handler = entry.isNative ?
            nativeHandler(element, entry.handler, args) :
            customHandler(element, entry.handler, type, false, args, false)
          if (entry[eventSupport])
            listener(entry[targetS], entry.eventType, entry.handler, true, entry.customType)
        }
  
      , del = function (selector, fn, $) {
              //TODO: findTarget (therefore $) is called twice, once for match and once for
              // setting e.currentTarget, fix this so it's only needed once
          var findTarget = function (target, root) {
                var i, array = typeof selector === 'string' ? $(selector, root) : selector
                for (; target && target !== root; target = target.parentNode) {
                  for (i = array.length; i--;) {
                    if (array[i] === target)
                      return target
                  }
                }
              }
            , handler = function (e) {
                var match = findTarget(e[targetS], this)
                match && fn.apply(match, arguments)
              }
  
          handler.__beanDel = {
              ft: findTarget // attach it here for customEvents to use too
            , selector: selector
            , $: $
          }
          return handler
        }
  
      , remove = function (element, typeSpec, fn) {
          var k, type, namespaces, i
            , rm = removeListener
            , isString = typeSpec && typeof typeSpec === 'string'
  
          if (isString && typeSpec.indexOf(' ') > 0) {
            // remove(el, 't1 t2 t3', fn) or remove(el, 't1 t2 t3')
            typeSpec = typeSpec.split(' ')
            for (i = typeSpec.length; i--;)
              remove(element, typeSpec[i], fn)
            return element
          }
          type = isString && typeSpec.replace(nameRegex, '')
          if (type && customEvents[type])
            type = customEvents[type].type
          if (!typeSpec || isString) {
            // remove(el) or remove(el, t1.ns) or remove(el, .ns) or remove(el, .ns1.ns2.ns3)
            if (namespaces = isString && typeSpec.replace(namespaceRegex, ''))
              namespaces = namespaces.split('.')
            rm(element, type, fn, namespaces)
          } else if (typeof typeSpec === 'function') {
            // remove(el, fn)
            rm(element, null, typeSpec)
          } else {
            // remove(el, { t1: fn1, t2, fn2 })
            for (k in typeSpec) {
              if (typeSpec.hasOwnProperty(k))
                remove(element, k, typeSpec[k])
            }
          }
          return element
        }
  
        // 5th argument, $=selector engine, is deprecated and will be removed
      , add = function (element, events, fn, delfn, $) {
          var type, types, i, args
            , originalFn = fn
            , isDel = fn && typeof fn === 'string'
  
          if (events && !fn && typeof events === 'object') {
            for (type in events) {
              if (events.hasOwnProperty(type))
                add.apply(this, [ element, type, events[type] ])
            }
          } else {
            args = arguments.length > 3 ? slice.call(arguments, 3) : []
            types = (isDel ? fn : events).split(' ')
            isDel && (fn = del(events, (originalFn = delfn), $ || selectorEngine)) && (args = slice.call(args, 1))
            // special case for one()
            this === ONE && (fn = once(remove, element, events, fn, originalFn))
            for (i = types.length; i--;) addListener(element, types[i], fn, originalFn, args)
          }
          return element
        }
  
      , one = function () {
          return add.apply(ONE, arguments)
        }
  
      , fireListener = W3C_MODEL ? function (isNative, type, element) {
          var evt = doc.createEvent(isNative ? 'HTMLEvents' : 'UIEvents')
          evt[isNative ? 'initEvent' : 'initUIEvent'](type, true, true, win, 1)
          element.dispatchEvent(evt)
        } : function (isNative, type, element) {
          element = targetElement(element, isNative)
          // if not-native then we're using onpropertychange so we just increment a custom property
          isNative ? element.fireEvent('on' + type, doc.createEventObject()) : element['_on' + type]++
        }
  
      , fire = function (element, type, args) {
          var i, j, l, names, handlers
            , types = type.split(' ')
  
          for (i = types.length; i--;) {
            type = types[i].replace(nameRegex, '')
            if (names = types[i].replace(namespaceRegex, ''))
              names = names.split('.')
            if (!names && !args && element[eventSupport]) {
              fireListener(nativeEvents[type], type, element)
            } else {
              // non-native event, either because of a namespace, arguments or a non DOM element
              // iterate over all listeners and manually 'fire'
              handlers = registry.get(element, type)
              args = [false].concat(args)
              for (j = 0, l = handlers.length; j < l; j++) {
                if (handlers[j].inNamespaces(names))
                  handlers[j].handler.apply(element, args)
              }
            }
          }
          return element
        }
  
      , clone = function (element, from, type) {
          var i = 0
            , handlers = registry.get(from, type)
            , l = handlers.length
            , args, beanDel
  
          for (;i < l; i++) {
            if (handlers[i].original) {
              beanDel = handlers[i].handler.__beanDel
              if (beanDel) {
                args = [ element, beanDel.selector, handlers[i].type, handlers[i].original, beanDel.$]
              } else
                args = [ element, handlers[i].type, handlers[i].original ]
              add.apply(null, args)
            }
          }
          return element
        }
  
      , bean = {
            add: add
          , one: one
          , remove: remove
          , clone: clone
          , fire: fire
          , setSelectorEngine: setSelectorEngine
          , noConflict: function () {
              context[name] = old
              return this
            }
        }
  
    if (win[attachEvent]) {
      // for IE, clean up on unload to avoid leaks
      var cleanup = function () {
        var i, entries = registry.entries()
        for (i in entries) {
          if (entries[i].type && entries[i].type !== 'unload')
            remove(entries[i].element, entries[i].type)
        }
        win[detachEvent]('onunload', cleanup)
        win.CollectGarbage && win.CollectGarbage()
      }
      win[attachEvent]('onunload', cleanup)
    }
  
    return bean
  })
  

  provide("bean", module.exports);

  !function ($) {
    var b = require('bean')
      , integrate = function (method, type, method2) {
          var _args = type ? [type] : []
          return function () {
            for (var i = 0, l = this.length; i < l; i++) {
              if (!arguments.length && method == 'add' && type) method = 'fire'
              b[method].apply(this, [this[i]].concat(_args, Array.prototype.slice.call(arguments, 0)))
            }
            return this
          }
        }
      , add = integrate('add')
      , remove = integrate('remove')
      , fire = integrate('fire')
  
      , methods = {
            on: add // NOTE: .on() is likely to change in the near future, don't rely on this as-is see https://github.com/fat/bean/issues/55
          , addListener: add
          , bind: add
          , listen: add
          , delegate: add
  
          , one: integrate('one')
  
          , off: remove
          , unbind: remove
          , unlisten: remove
          , removeListener: remove
          , undelegate: remove
  
          , emit: fire
          , trigger: fire
  
          , cloneEvents: integrate('clone')
  
          , hover: function (enter, leave, i) { // i for internal
              for (i = this.length; i--;) {
                b.add.call(this, this[i], 'mouseenter', enter)
                b.add.call(this, this[i], 'mouseleave', leave)
              }
              return this
            }
        }
  
      , shortcuts =
           ('blur change click dblclick error focus focusin focusout keydown keypress '
          + 'keyup load mousedown mouseenter mouseleave mouseout mouseover mouseup '
          + 'mousemove resize scroll select submit unload').split(' ')
  
    for (var i = shortcuts.length; i--;) {
      methods[shortcuts[i]] = integrate('add', shortcuts[i])
    }
  
    b.setSelectorEngine($)
  
    $.ender(methods, true)
  }(ender)
  

}());

(function () {

  var module = { exports: {} }, exports = module.exports;

  /*!
    * Bonzo: DOM Utility (c) Dustin Diaz 2012
    * https://github.com/ded/bonzo
    * License MIT
    */
  (function (name, definition, context) {
    if (typeof module != 'undefined' && module.exports) module.exports = definition()
    else if (typeof context['define'] == 'function' && context['define']['amd']) define(name, definition)
    else context[name] = definition()
  })('bonzo', function() {
    var win = window
      , doc = win.document
      , html = doc.documentElement
      , parentNode = 'parentNode'
      , query = null // used for setting a selector engine host
      , specialAttributes = /^(checked|value|selected|disabled)$/i
      , specialTags = /^(select|fieldset|table|tbody|tfoot|td|tr|colgroup)$/i // tags that we have trouble inserting *into*
      , table = ['<table>', '</table>', 1]
      , td = ['<table><tbody><tr>', '</tr></tbody></table>', 3]
      , option = ['<select>', '</select>', 1]
      , noscope = ['_', '', 0, 1]
      , tagMap = { // tags that we have trouble *inserting*
            thead: table, tbody: table, tfoot: table, colgroup: table, caption: table
          , tr: ['<table><tbody>', '</tbody></table>', 2]
          , th: td , td: td
          , col: ['<table><colgroup>', '</colgroup></table>', 2]
          , fieldset: ['<form>', '</form>', 1]
          , legend: ['<form><fieldset>', '</fieldset></form>', 2]
          , option: option, optgroup: option
          , script: noscope, style: noscope, link: noscope, param: noscope, base: noscope
        }
      , stateAttributes = /^(checked|selected|disabled)$/
      , ie = /msie/i.test(navigator.userAgent)
      , hasClass, addClass, removeClass
      , uidMap = {}
      , uuids = 0
      , digit = /^-?[\d\.]+$/
      , dattr = /^data-(.+)$/
      , px = 'px'
      , setAttribute = 'setAttribute'
      , getAttribute = 'getAttribute'
      , byTag = 'getElementsByTagName'
      , features = function() {
          var e = doc.createElement('p')
          e.innerHTML = '<a href="#x">x</a><table style="float:left;"></table>'
          return {
            hrefExtended: e[byTag]('a')[0][getAttribute]('href') != '#x' // IE < 8
          , autoTbody: e[byTag]('tbody').length !== 0 // IE < 8
          , computedStyle: doc.defaultView && doc.defaultView.getComputedStyle
          , cssFloat: e[byTag]('table')[0].style.styleFloat ? 'styleFloat' : 'cssFloat'
          , transform: function () {
              var props = ['webkitTransform', 'MozTransform', 'OTransform', 'msTransform', 'Transform'], i
              for (i = 0; i < props.length; i++) {
                if (props[i] in e.style) return props[i]
              }
            }()
          , classList: 'classList' in e
          , opasity: function () {
              return typeof doc.createElement('a').style.opacity !== 'undefined'
            }()
          }
        }()
      , trimReplace = /(^\s*|\s*$)/g
      , whitespaceRegex = /\s+/
      , toString = String.prototype.toString
      , unitless = { lineHeight: 1, zoom: 1, zIndex: 1, opacity: 1, boxFlex: 1, WebkitBoxFlex: 1, MozBoxFlex: 1 }
      , trim = String.prototype.trim ?
          function (s) {
            return s.trim()
          } :
          function (s) {
            return s.replace(trimReplace, '')
          }
  
  
    /**
     * @param {string} c a class name to test
     * @return {boolean}
     */
    function classReg(c) {
      return new RegExp("(^|\\s+)" + c + "(\\s+|$)")
    }
  
  
    /**
     * @param {Bonzo|Array} ar
     * @param {function(Object, number, (Bonzo|Array))} fn
     * @param {Object=} opt_scope
     * @param {boolean=} opt_rev
     * @return {Bonzo|Array}
     */
    function each(ar, fn, opt_scope, opt_rev) {
      var ind, i = 0, l = ar.length
      for (; i < l; i++) {
        ind = opt_rev ? ar.length - i - 1 : i
        fn.call(opt_scope || ar[ind], ar[ind], ind, ar)
      }
      return ar
    }
  
  
    /**
     * @param {Bonzo|Array} ar
     * @param {function(Object, number, (Bonzo|Array))} fn
     * @param {Object=} opt_scope
     * @return {Bonzo|Array}
     */
    function deepEach(ar, fn, opt_scope) {
      for (var i = 0, l = ar.length; i < l; i++) {
        if (isNode(ar[i])) {
          deepEach(ar[i].childNodes, fn, opt_scope)
          fn.call(opt_scope || ar[i], ar[i], i, ar)
        }
      }
      return ar
    }
  
  
    /**
     * @param {string} s
     * @return {string}
     */
    function camelize(s) {
      return s.replace(/-(.)/g, function (m, m1) {
        return m1.toUpperCase()
      })
    }
  
  
    /**
     * @param {string} s
     * @return {string}
     */
    function decamelize(s) {
      return s ? s.replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase() : s
    }
  
  
    /**
     * @param {Element} el
     * @return {*}
     */
    function data(el) {
      el[getAttribute]('data-node-uid') || el[setAttribute]('data-node-uid', ++uuids)
      var uid = el[getAttribute]('data-node-uid')
      return uidMap[uid] || (uidMap[uid] = {})
    }
  
  
    /**
     * removes the data associated with an element
     * @param {Element} el
     */
    function clearData(el) {
      var uid = el[getAttribute]('data-node-uid')
      if (uid) delete uidMap[uid]
    }
  
  
    function dataValue(d) {
      var f
      try {
        return (d === null || d === undefined) ? undefined :
          d === 'true' ? true :
            d === 'false' ? false :
              d === 'null' ? null :
                (f = parseFloat(d)) == d ? f : d;
      } catch(e) {}
      return undefined
    }
  
    function isNode(node) {
      return node && node.nodeName && (node.nodeType == 1 || node.nodeType == 11)
    }
  
  
    /**
     * @param {Bonzo|Array} ar
     * @param {function(Object, number, (Bonzo|Array))} fn
     * @param {Object=} opt_scope
     * @return {boolean} whether `some`thing was found
     */
    function some(ar, fn, opt_scope) {
      for (var i = 0, j = ar.length; i < j; ++i) if (fn.call(opt_scope || null, ar[i], i, ar)) return true
      return false
    }
  
  
    /**
     * this could be a giant enum of CSS properties
     * but in favor of file size sans-closure deadcode optimizations
     * we're just asking for any ol string
     * then it gets transformed into the appropriate style property for JS access
     * @param {string} p
     * @return {string}
     */
    function styleProperty(p) {
        (p == 'transform' && (p = features.transform)) ||
          (/^transform-?[Oo]rigin$/.test(p) && (p = features.transform + "Origin")) ||
          (p == 'float' && (p = features.cssFloat))
        return p ? camelize(p) : null
    }
  
    var getStyle = features.computedStyle ?
      function (el, property) {
        var value = null
          , computed = doc.defaultView.getComputedStyle(el, '')
        computed && (value = computed[property])
        return el.style[property] || value
      } :
  
      (ie && html.currentStyle) ?
  
      /**
       * @param {Element} el
       * @param {string} property
       * @return {string|number}
       */
      function (el, property) {
        if (property == 'opacity' && !features.opasity) {
          var val = 100
          try {
            val = el['filters']['DXImageTransform.Microsoft.Alpha'].opacity
          } catch (e1) {
            try {
              val = el['filters']('alpha').opacity
            } catch (e2) {}
          }
          return val / 100
        }
        var value = el.currentStyle ? el.currentStyle[property] : null
        return el.style[property] || value
      } :
  
      function (el, property) {
        return el.style[property]
      }
  
    // this insert method is intense
    function insert(target, host, fn, rev) {
      var i = 0, self = host || this, r = []
        // target nodes could be a css selector if it's a string and a selector engine is present
        // otherwise, just use target
        , nodes = query && typeof target == 'string' && target.charAt(0) != '<' ? query(target) : target
      // normalize each node in case it's still a string and we need to create nodes on the fly
      each(normalize(nodes), function (t, j) {
        each(self, function (el) {
          fn(t, r[i++] = j > 0 ? cloneNode(self, el) : el)
        }, null, rev)
      }, this, rev)
      self.length = i
      each(r, function (e) {
        self[--i] = e
      }, null, !rev)
      return self
    }
  
  
    /**
     * sets an element to an explicit x/y position on the page
     * @param {Element} el
     * @param {?number} x
     * @param {?number} y
     */
    function xy(el, x, y) {
      var $el = bonzo(el)
        , style = $el.css('position')
        , offset = $el.offset()
        , rel = 'relative'
        , isRel = style == rel
        , delta = [parseInt($el.css('left'), 10), parseInt($el.css('top'), 10)]
  
      if (style == 'static') {
        $el.css('position', rel)
        style = rel
      }
  
      isNaN(delta[0]) && (delta[0] = isRel ? 0 : el.offsetLeft)
      isNaN(delta[1]) && (delta[1] = isRel ? 0 : el.offsetTop)
  
      x != null && (el.style.left = x - offset.left + delta[0] + px)
      y != null && (el.style.top = y - offset.top + delta[1] + px)
  
    }
  
    // classList support for class management
    // altho to be fair, the api sucks because it won't accept multiple classes at once
    if (features.classList) {
      hasClass = function (el, c) {
        return el.classList.contains(c)
      }
      addClass = function (el, c) {
        el.classList.add(c)
      }
      removeClass = function (el, c) {
        el.classList.remove(c)
      }
    }
    else {
      hasClass = function (el, c) {
        return classReg(c).test(el.className)
      }
      addClass = function (el, c) {
        el.className = trim(el.className + ' ' + c)
      }
      removeClass = function (el, c) {
        el.className = trim(el.className.replace(classReg(c), ' '))
      }
    }
  
  
    /**
     * this allows method calling for setting values
     *
     * @example
     * bonzo(elements).css('color', function (el) {
     *   return el.getAttribute('data-original-color')
     * })
     *
     * @param {Element} el
     * @param {function (Element)|string}
     * @return {string}
     */
    function setter(el, v) {
      return typeof v == 'function' ? v(el) : v
    }
  
    /**
     * @constructor
     * @param {Array.<Element>|Element|Node|string} elements
     */
    function Bonzo(elements) {
      this.length = 0
      if (elements) {
        elements = typeof elements !== 'string' &&
          !elements.nodeType &&
          typeof elements.length !== 'undefined' ?
            elements :
            [elements]
        this.length = elements.length
        for (var i = 0; i < elements.length; i++) this[i] = elements[i]
      }
    }
  
    Bonzo.prototype = {
  
        /**
         * @param {number} index
         * @return {Element|Node}
         */
        get: function (index) {
          return this[index] || null
        }
  
        // itetators
        /**
         * @param {function(Element|Node)} fn
         * @param {Object=} opt_scope
         * @return {Bonzo}
         */
      , each: function (fn, opt_scope) {
          return each(this, fn, opt_scope)
        }
  
        /**
         * @param {Function} fn
         * @param {Object=} opt_scope
         * @return {Bonzo}
         */
      , deepEach: function (fn, opt_scope) {
          return deepEach(this, fn, opt_scope)
        }
  
  
        /**
         * @param {Function} fn
         * @param {Function=} opt_reject
         * @return {Array}
         */
      , map: function (fn, opt_reject) {
          var m = [], n, i
          for (i = 0; i < this.length; i++) {
            n = fn.call(this, this[i], i)
            opt_reject ? (opt_reject(n) && m.push(n)) : m.push(n)
          }
          return m
        }
  
      // text and html inserters!
  
      /**
       * @param {string} h the HTML to insert
       * @param {boolean=} opt_text whether to set or get text content
       * @return {Bonzo|string}
       */
      , html: function (h, opt_text) {
          var method = opt_text
                ? html.textContent === undefined ? 'innerText' : 'textContent'
                : 'innerHTML'
            , that = this
            , append = function (el, i) {
                each(normalize(h, that, i), function (node) {
                  el.appendChild(node)
                })
              }
            , updateElement = function (el, i) {
                try {
                  if (opt_text || (typeof h == 'string' && !specialTags.test(el.tagName))) {
                    return el[method] = h
                  }
                } catch (e) {}
                append(el, i)
              }
          return typeof h != 'undefined'
            ? this.empty().each(updateElement)
            : this[0] ? this[0][method] : ''
        }
  
        /**
         * @param {string=} opt_text the text to set, otherwise this is a getter
         * @return {Bonzo|string}
         */
      , text: function (opt_text) {
          return this.html(opt_text, true)
        }
  
        // more related insertion methods
  
        /**
         * @param {Bonzo|string|Element|Array} node
         * @return {Bonzo}
         */
      , append: function (node) {
          var that = this
          return this.each(function (el, i) {
            each(normalize(node, that, i), function (i) {
              el.appendChild(i)
            })
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} node
         * @return {Bonzo}
         */
      , prepend: function (node) {
          var that = this
          return this.each(function (el, i) {
            var first = el.firstChild
            each(normalize(node, that, i), function (i) {
              el.insertBefore(i, first)
            })
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} target the location for which you'll insert your new content
         * @param {Object=} opt_host an optional host scope (primarily used when integrated with Ender)
         * @return {Bonzo}
         */
      , appendTo: function (target, opt_host) {
          return insert.call(this, target, opt_host, function (t, el) {
            t.appendChild(el)
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} target the location for which you'll insert your new content
         * @param {Object=} opt_host an optional host scope (primarily used when integrated with Ender)
         * @return {Bonzo}
         */
      , prependTo: function (target, opt_host) {
          return insert.call(this, target, opt_host, function (t, el) {
            t.insertBefore(el, t.firstChild)
          }, 1)
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} node
         * @return {Bonzo}
         */
      , before: function (node) {
          var that = this
          return this.each(function (el, i) {
            each(normalize(node, that, i), function (i) {
              el[parentNode].insertBefore(i, el)
            })
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} node
         * @return {Bonzo}
         */
      , after: function (node) {
          var that = this
          return this.each(function (el, i) {
            each(normalize(node, that, i), function (i) {
              el[parentNode].insertBefore(i, el.nextSibling)
            }, null, 1)
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} target the location for which you'll insert your new content
         * @param {Object=} opt_host an optional host scope (primarily used when integrated with Ender)
         * @return {Bonzo}
         */
      , insertBefore: function (target, opt_host) {
          return insert.call(this, target, opt_host, function (t, el) {
            t[parentNode].insertBefore(el, t)
          })
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} target the location for which you'll insert your new content
         * @param {Object=} opt_host an optional host scope (primarily used when integrated with Ender)
         * @return {Bonzo}
         */
      , insertAfter: function (target, opt_host) {
          return insert.call(this, target, opt_host, function (t, el) {
            var sibling = t.nextSibling
            sibling ?
              t[parentNode].insertBefore(el, sibling) :
              t[parentNode].appendChild(el)
          }, 1)
        }
  
  
        /**
         * @param {Bonzo|string|Element|Array} node
         * @param {Object=} opt_host an optional host scope (primarily used when integrated with Ender)
         * @return {Bonzo}
         */
      , replaceWith: function (node, opt_host) {
          var ret = bonzo(normalize(node)).insertAfter(this, opt_host)
          this.remove()
          Bonzo.call(opt_host || this, ret)
          return opt_host || this
        }
  
        // class management
  
        /**
         * @param {string} c
         * @return {Bonzo}
         */
      , addClass: function (c) {
          c = toString.call(c).split(whitespaceRegex)
          return this.each(function (el) {
            // we `each` here so you can do $el.addClass('foo bar')
            each(c, function (c) {
              if (c && !hasClass(el, setter(el, c)))
                addClass(el, setter(el, c))
            })
          })
        }
  
  
        /**
         * @param {string} c
         * @return {Bonzo}
         */
      , removeClass: function (c) {
          c = toString.call(c).split(whitespaceRegex)
          return this.each(function (el) {
            each(c, function (c) {
              if (c && hasClass(el, setter(el, c)))
                removeClass(el, setter(el, c))
            })
          })
        }
  
  
        /**
         * @param {string} c
         * @return {boolean}
         */
      , hasClass: function (c) {
          c = toString.call(c).split(whitespaceRegex)
          return some(this, function (el) {
            return some(c, function (c) {
              return c && hasClass(el, c)
            })
          })
        }
  
  
        /**
         * @param {string} c classname to toggle
         * @param {boolean=} opt_condition whether to add or remove the class straight away
         * @return {Bonzo}
         */
      , toggleClass: function (c, opt_condition) {
          c = toString.call(c).split(whitespaceRegex)
          return this.each(function (el) {
            each(c, function (c) {
              if (c) {
                typeof opt_condition !== 'undefined' ?
                  opt_condition ? addClass(el, c) : removeClass(el, c) :
                  hasClass(el, c) ? removeClass(el, c) : addClass(el, c)
              }
            })
          })
        }
  
        // display togglers
  
        /**
         * @param {string=} opt_type useful to set back to anything other than an empty string
         * @return {Bonzo}
         */
      , show: function (opt_type) {
          opt_type = typeof opt_type == 'string' ? opt_type : ''
          return this.each(function (el) {
            el.style.display = opt_type
          })
        }
  
  
        /**
         * @return {Bonzo}
         */
      , hide: function () {
          return this.each(function (el) {
            el.style.display = 'none'
          })
        }
  
  
        /**
         * @param {Function=} opt_callback
         * @param {string=} opt_type
         * @return {Bonzo}
         */
      , toggle: function (opt_callback, opt_type) {
          opt_type = typeof opt_type == 'string' ? opt_type : '';
          typeof opt_callback != 'function' && (opt_callback = null)
          return this.each(function (el) {
            el.style.display = (el.offsetWidth || el.offsetHeight) ? 'none' : opt_type;
            opt_callback && opt_callback.call(el)
          })
        }
  
  
        // DOM Walkers & getters
  
        /**
         * @return {Element|Node}
         */
      , first: function () {
          return bonzo(this.length ? this[0] : [])
        }
  
  
        /**
         * @return {Element|Node}
         */
      , last: function () {
          return bonzo(this.length ? this[this.length - 1] : [])
        }
  
  
        /**
         * @return {Element|Node}
         */
      , next: function () {
          return this.related('nextSibling')
        }
  
  
        /**
         * @return {Element|Node}
         */
      , previous: function () {
          return this.related('previousSibling')
        }
  
  
        /**
         * @return {Element|Node}
         */
      , parent: function() {
          return this.related(parentNode)
        }
  
  
        /**
         * @private
         * @param {string} method the directional DOM method
         * @return {Element|Node}
         */
      , related: function (method) {
          return this.map(
            function (el) {
              el = el[method]
              while (el && el.nodeType !== 1) {
                el = el[method]
              }
              return el || 0
            },
            function (el) {
              return el
            }
          )
        }
  
  
        /**
         * @return {Bonzo}
         */
      , focus: function () {
          this.length && this[0].focus()
          return this
        }
  
  
        /**
         * @return {Bonzo}
         */
      , blur: function () {
          this.length && this[0].blur()
          return this
        }
  
        // style getter setter & related methods
  
        /**
         * @param {Object|string} o
         * @param {string=} opt_v
         * @return {Bonzo|string}
         */
      , css: function (o, opt_v) {
          var p, iter = o
          // is this a request for just getting a style?
          if (opt_v === undefined && typeof o == 'string') {
            // repurpose 'v'
            opt_v = this[0]
            if (!opt_v) return null
            if (opt_v === doc || opt_v === win) {
              p = (opt_v === doc) ? bonzo.doc() : bonzo.viewport()
              return o == 'width' ? p.width : o == 'height' ? p.height : ''
            }
            return (o = styleProperty(o)) ? getStyle(opt_v, o) : null
          }
  
          if (typeof o == 'string') {
            iter = {}
            iter[o] = opt_v
          }
  
          if (ie && iter.opacity) {
            // oh this 'ol gamut
            iter.filter = 'alpha(opacity=' + (iter.opacity * 100) + ')'
            // give it layout
            iter.zoom = o.zoom || 1;
            delete iter.opacity;
          }
  
          function fn(el, p, v) {
            for (var k in iter) {
              if (iter.hasOwnProperty(k)) {
                v = iter[k];
                // change "5" to "5px" - unless you're line-height, which is allowed
                (p = styleProperty(k)) && digit.test(v) && !(p in unitless) && (v += px)
                try { el.style[p] = setter(el, v) } catch(e) {}
              }
            }
          }
          return this.each(fn)
        }
  
  
        /**
         * @param {number=} opt_x
         * @param {number=} opt_y
         * @return {Bonzo|number}
         */
      , offset: function (opt_x, opt_y) {
          if (typeof opt_x == 'number' || typeof opt_y == 'number') {
            return this.each(function (el) {
              xy(el, opt_x, opt_y)
            })
          }
          if (!this[0]) return {
              top: 0
            , left: 0
            , height: 0
            , width: 0
          }
          var el = this[0]
            , width = el.offsetWidth
            , height = el.offsetHeight
            , top = el.offsetTop
            , left = el.offsetLeft
          while (el = el.offsetParent) {
            top = top + el.offsetTop
            left = left + el.offsetLeft
  
            if (el != doc.body) {
              top -= el.scrollTop
              left -= el.scrollLeft
            }
          }
  
          return {
              top: top
            , left: left
            , height: height
            , width: width
          }
        }
  
  
        /**
         * @return {number}
         */
      , dim: function () {
          if (!this.length) return { height: 0, width: 0 }
          var el = this[0]
            , orig = !el.offsetWidth && !el.offsetHeight ?
               // el isn't visible, can't be measured properly, so fix that
               function (t) {
                 var s = {
                     position: el.style.position || ''
                   , visibility: el.style.visibility || ''
                   , display: el.style.display || ''
                 }
                 t.first().css({
                     position: 'absolute'
                   , visibility: 'hidden'
                   , display: 'block'
                 })
                 return s
              }(this) : null
            , width = el.offsetWidth
            , height = el.offsetHeight
  
          orig && this.first().css(orig)
          return {
              height: height
            , width: width
          }
        }
  
        // attributes are hard. go shopping
  
        /**
         * @param {string} k an attribute to get or set
         * @param {string=} opt_v the value to set
         * @return {Bonzo|string}
         */
      , attr: function (k, opt_v) {
          var el = this[0]
          if (typeof k != 'string' && !(k instanceof String)) {
            for (var n in k) {
              k.hasOwnProperty(n) && this.attr(n, k[n])
            }
            return this
          }
          return typeof opt_v == 'undefined' ?
            !el ? null : specialAttributes.test(k) ?
              stateAttributes.test(k) && typeof el[k] == 'string' ?
                true : el[k] : (k == 'href' || k =='src') && features.hrefExtended ?
                  el[getAttribute](k, 2) : el[getAttribute](k) :
            this.each(function (el) {
              specialAttributes.test(k) ? (el[k] = setter(el, opt_v)) : el[setAttribute](k, setter(el, opt_v))
            })
        }
  
  
        /**
         * @param {string} k
         * @return {Bonzo}
         */
      , removeAttr: function (k) {
          return this.each(function (el) {
            stateAttributes.test(k) ? (el[k] = false) : el.removeAttribute(k)
          })
        }
  
  
        /**
         * @param {string=} opt_s
         * @return {Bonzo|string}
         */
      , val: function (s) {
          return (typeof s == 'string') ?
            this.attr('value', s) :
            this.length ? this[0].value : null
        }
  
        // use with care and knowledge. this data() method uses data attributes on the DOM nodes
        // to do this differently costs a lot more code. c'est la vie
        /**
         * @param {string|Object=} opt_k the key for which to get or set data
         * @param {Object=} opt_v
         * @return {Bonzo|Object}
         */
      , data: function (opt_k, opt_v) {
          var el = this[0], o, m
          if (typeof opt_v === 'undefined') {
            if (!el) return null
            o = data(el)
            if (typeof opt_k === 'undefined') {
              each(el.attributes, function (a) {
                (m = ('' + a.name).match(dattr)) && (o[camelize(m[1])] = dataValue(a.value))
              })
              return o
            } else {
              if (typeof o[opt_k] === 'undefined')
                o[opt_k] = dataValue(this.attr('data-' + decamelize(opt_k)))
              return o[opt_k]
            }
          } else {
            return this.each(function (el) { data(el)[opt_k] = opt_v })
          }
        }
  
        // DOM detachment & related
  
        /**
         * @return {Bonzo}
         */
      , remove: function () {
          this.deepEach(clearData)
  
          return this.each(function (el) {
            el[parentNode] && el[parentNode].removeChild(el)
          })
        }
  
  
        /**
         * @return {Bonzo}
         */
      , empty: function () {
          return this.each(function (el) {
            deepEach(el.childNodes, clearData)
  
            while (el.firstChild) {
              el.removeChild(el.firstChild)
            }
          })
        }
  
  
        /**
         * @return {Bonzo}
         */
      , detach: function () {
          return this.each(function (el) {
            el[parentNode].removeChild(el)
          })
        }
  
        // who uses a mouse anyway? oh right.
  
        /**
         * @param {number} y
         */
      , scrollTop: function (y) {
          return scroll.call(this, null, y, 'y')
        }
  
  
        /**
         * @param {number} x
         */
      , scrollLeft: function (x) {
          return scroll.call(this, x, null, 'x')
        }
  
    }
  
    function normalize(node, host, clone) {
      var i, l, ret
      if (typeof node == 'string') return bonzo.create(node)
      if (isNode(node)) node = [ node ]
      if (clone) {
        ret = [] // don't change original array
        for (i = 0, l = node.length; i < l; i++) ret[i] = cloneNode(host, node[i])
        return ret
      }
      return node
    }
  
    function cloneNode(host, el) {
      var c = el.cloneNode(true)
        , cloneElems
        , elElems
  
      // check for existence of an event cloner
      // preferably https://github.com/fat/bean
      // otherwise Bonzo won't do this for you
      if (host.$ && typeof host.cloneEvents == 'function') {
        host.$(c).cloneEvents(el)
  
        // clone events from every child node
        cloneElems = host.$(c).find('*')
        elElems = host.$(el).find('*')
  
        for (var i = 0; i < elElems.length; i++)
          host.$(cloneElems[i]).cloneEvents(elElems[i])
      }
      return c
    }
  
    function scroll(x, y, type) {
      var el = this[0]
      if (!el) return this
      if (x == null && y == null) {
        return (isBody(el) ? getWindowScroll() : { x: el.scrollLeft, y: el.scrollTop })[type]
      }
      if (isBody(el)) {
        win.scrollTo(x, y)
      } else {
        x != null && (el.scrollLeft = x)
        y != null && (el.scrollTop = y)
      }
      return this
    }
  
    function isBody(element) {
      return element === win || (/^(?:body|html)$/i).test(element.tagName)
    }
  
    function getWindowScroll() {
      return { x: win.pageXOffset || html.scrollLeft, y: win.pageYOffset || html.scrollTop }
    }
  
    /**
     * @param {Array.<Element>|Element|Node|string} els
     * @return {Bonzo}
     */
    function bonzo(els) {
      return new Bonzo(els)
    }
  
    bonzo.setQueryEngine = function (q) {
      query = q;
      delete bonzo.setQueryEngine
    }
  
    bonzo.aug = function (o, target) {
      // for those standalone bonzo users. this love is for you.
      for (var k in o) {
        o.hasOwnProperty(k) && ((target || Bonzo.prototype)[k] = o[k])
      }
    }
  
    bonzo.create = function (node) {
      // hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
      return typeof node == 'string' && node !== '' ?
        function () {
          var tag = /^\s*<([^\s>]+)/.exec(node)
            , el = doc.createElement('div')
            , els = []
            , p = tag ? tagMap[tag[1].toLowerCase()] : null
            , dep = p ? p[2] + 1 : 1
            , ns = p && p[3]
            , pn = parentNode
            , tb = features.autoTbody && p && p[0] == '<table>' && !(/<tbody/i).test(node)
  
          el.innerHTML = p ? (p[0] + node + p[1]) : node
          while (dep--) el = el.firstChild
          // for IE NoScope, we may insert cruft at the begining just to get it to work
          if (ns && el && el.nodeType !== 1) el = el.nextSibling
          do {
            // tbody special case for IE<8, creates tbody on any empty table
            // we don't want it if we're just after a <thead>, <caption>, etc.
            if ((!tag || el.nodeType == 1) && (!tb || el.tagName.toLowerCase() != 'tbody')) {
              els.push(el)
            }
          } while (el = el.nextSibling)
          // IE < 9 gives us a parentNode which messes up insert() check for cloning
          // `dep` > 1 can also cause problems with the insert() check (must do this last)
          each(els, function(el) { el[pn] && el[pn].removeChild(el) })
          return els
        }() : isNode(node) ? [node.cloneNode(true)] : []
    }
  
    bonzo.doc = function () {
      var vp = bonzo.viewport()
      return {
          width: Math.max(doc.body.scrollWidth, html.scrollWidth, vp.width)
        , height: Math.max(doc.body.scrollHeight, html.scrollHeight, vp.height)
      }
    }
  
    bonzo.firstChild = function (el) {
      for (var c = el.childNodes, i = 0, j = (c && c.length) || 0, e; i < j; i++) {
        if (c[i].nodeType === 1) e = c[j = i]
      }
      return e
    }
  
    bonzo.viewport = function () {
      return {
          width: ie ? html.clientWidth : self.innerWidth
        , height: ie ? html.clientHeight : self.innerHeight
      }
    }
  
    bonzo.isAncestor = 'compareDocumentPosition' in html ?
      function (container, element) {
        return (container.compareDocumentPosition(element) & 16) == 16
      } : 'contains' in html ?
      function (container, element) {
        return container !== element && container.contains(element);
      } :
      function (container, element) {
        while (element = element[parentNode]) {
          if (element === container) {
            return true
          }
        }
        return false
      }
  
    return bonzo
  }, this); // the only line we care about using a semi-colon. placed here for concatenation tools
  

  provide("bonzo", module.exports);

  (function ($) {
  
    var b = require('bonzo')
    b.setQueryEngine($)
    $.ender(b)
    $.ender(b(), true)
    $.ender({
      create: function (node) {
        return $(b.create(node))
      }
    })
  
    $.id = function (id) {
      return $([document.getElementById(id)])
    }
  
    function indexOf(ar, val) {
      for (var i = 0; i < ar.length; i++) if (ar[i] === val) return i
      return -1
    }
  
    function uniq(ar) {
      var r = [], i = 0, j = 0, k, item, inIt
      for (; item = ar[i]; ++i) {
        inIt = false
        for (k = 0; k < r.length; ++k) {
          if (r[k] === item) {
            inIt = true; break
          }
        }
        if (!inIt) r[j++] = item
      }
      return r
    }
  
    $.ender({
      parents: function (selector, closest) {
        if (!this.length) return this
        var collection = $(selector), j, k, p, r = []
        for (j = 0, k = this.length; j < k; j++) {
          p = this[j]
          while (p = p.parentNode) {
            if (~indexOf(collection, p)) {
              r.push(p)
              if (closest) break;
            }
          }
        }
        return $(uniq(r))
      }
  
    , parent: function() {
        return $(uniq(b(this).parent()))
      }
  
    , closest: function (selector) {
        return this.parents(selector, true)
      }
  
    , first: function () {
        return $(this.length ? this[0] : this)
      }
  
    , last: function () {
        return $(this.length ? this[this.length - 1] : [])
      }
  
    , next: function () {
        return $(b(this).next())
      }
  
    , previous: function () {
        return $(b(this).previous())
      }
  
    , appendTo: function (t) {
        return b(this.selector).appendTo(t, this)
      }
  
    , prependTo: function (t) {
        return b(this.selector).prependTo(t, this)
      }
  
    , insertAfter: function (t) {
        return b(this.selector).insertAfter(t, this)
      }
  
    , insertBefore: function (t) {
        return b(this.selector).insertBefore(t, this)
      }
  
    , replaceWith: function (t) {
        return b(this.selector).replaceWith(t, this)
      }
  
    , siblings: function () {
        var i, l, p, r = []
        for (i = 0, l = this.length; i < l; i++) {
          p = this[i]
          while (p = p.previousSibling) p.nodeType == 1 && r.push(p)
          p = this[i]
          while (p = p.nextSibling) p.nodeType == 1 && r.push(p)
        }
        return $(r)
      }
  
    , children: function () {
        var i, l, el, r = []
        for (i = 0, l = this.length; i < l; i++) {
          if (!(el = b.firstChild(this[i]))) continue;
          r.push(el)
          while (el = el.nextSibling) el.nodeType == 1 && r.push(el)
        }
        return $(uniq(r))
      }
  
    , height: function (v) {
        return dimension.call(this, 'height', v)
      }
  
    , width: function (v) {
        return dimension.call(this, 'width', v)
      }
    }, true)
  
    /**
     * @param {string} type either width or height
     * @param {number=} opt_v becomes a setter instead of a getter
     * @return {number}
     */
    function dimension(type, opt_v) {
      return typeof opt_v == 'undefined'
        ? b(this).dim()[type]
        : this.css(type, opt_v)
    }
  }(ender));

}());

(function () {

  var module = { exports: {} }, exports = module.exports;

  /*!
    * domready (c) Dustin Diaz 2012 - License MIT
    */
  !function (name, definition) {
    if (typeof module != 'undefined') module.exports = definition()
    else if (typeof define == 'function' && typeof define.amd == 'object') define(definition)
    else this[name] = definition()
  }('domready', function (ready) {
  
    var fns = [], fn, f = false
      , doc = document
      , testEl = doc.documentElement
      , hack = testEl.doScroll
      , domContentLoaded = 'DOMContentLoaded'
      , addEventListener = 'addEventListener'
      , onreadystatechange = 'onreadystatechange'
      , readyState = 'readyState'
      , loaded = /^loade|c/.test(doc[readyState])
  
    function flush(f) {
      loaded = 1
      while (f = fns.shift()) f()
    }
  
    doc[addEventListener] && doc[addEventListener](domContentLoaded, fn = function () {
      doc.removeEventListener(domContentLoaded, fn, f)
      flush()
    }, f)
  
  
    hack && doc.attachEvent(onreadystatechange, fn = function () {
      if (/^c/.test(doc[readyState])) {
        doc.detachEvent(onreadystatechange, fn)
        flush()
      }
    })
  
    return (ready = hack ?
      function (fn) {
        self != top ?
          loaded ? fn() : fns.push(fn) :
          function () {
            try {
              testEl.doScroll('left')
            } catch (e) {
              return setTimeout(function() { ready(fn) }, 50)
            }
            fn()
          }()
      } :
      function (fn) {
        loaded ? fn() : fns.push(fn)
      })
  })

  provide("domready", module.exports);

  !function ($) {
    var ready = require('domready')
    $.ender({domReady: ready})
    $.ender({
      ready: function (f) {
        ready(f)
        return this
      }
    }, true)
  }(ender);

}());

(function () {

  var module = { exports: {} }, exports = module.exports;

  /*!
    * @preserve Qwery - A Blazing Fast query selector engine
    * https://github.com/ded/qwery
    * copyright Dustin Diaz & Jacob Thornton 2012
    * MIT License
    */
  
  (function (name, definition, context) {
    if (typeof module != 'undefined' && module.exports) module.exports = definition()
    else if (typeof context['define'] == 'function' && context['define']['amd']) define(name, definition)
    else context[name] = definition()
  })('qwery', function () {
    var doc = document
      , html = doc.documentElement
      , byClass = 'getElementsByClassName'
      , byTag = 'getElementsByTagName'
      , qSA = 'querySelectorAll'
      , useNativeQSA = 'useNativeQSA'
      , tagName = 'tagName'
      , nodeType = 'nodeType'
      , select // main select() method, assign later
  
      , id = /#([\w\-]+)/
      , clas = /\.[\w\-]+/g
      , idOnly = /^#([\w\-]+)$/
      , classOnly = /^\.([\w\-]+)$/
      , tagOnly = /^([\w\-]+)$/
      , tagAndOrClass = /^([\w]+)?\.([\w\-]+)$/
      , splittable = /(^|,)\s*[>~+]/
      , normalizr = /^\s+|\s*([,\s\+\~>]|$)\s*/g
      , splitters = /[\s\>\+\~]/
      , splittersMore = /(?![\s\w\-\/\?\&\=\:\.\(\)\!,@#%<>\{\}\$\*\^'"]*\]|[\s\w\+\-]*\))/
      , specialChars = /([.*+?\^=!:${}()|\[\]\/\\])/g
      , simple = /^(\*|[a-z0-9]+)?(?:([\.\#]+[\w\-\.#]+)?)/
      , attr = /\[([\w\-]+)(?:([\|\^\$\*\~]?\=)['"]?([ \w\-\/\?\&\=\:\.\(\)\!,@#%<>\{\}\$\*\^]+)["']?)?\]/
      , pseudo = /:([\w\-]+)(\(['"]?([^()]+)['"]?\))?/
      , easy = new RegExp(idOnly.source + '|' + tagOnly.source + '|' + classOnly.source)
      , dividers = new RegExp('(' + splitters.source + ')' + splittersMore.source, 'g')
      , tokenizr = new RegExp(splitters.source + splittersMore.source)
      , chunker = new RegExp(simple.source + '(' + attr.source + ')?' + '(' + pseudo.source + ')?')
      , walker = {
          ' ': function (node) {
            return node && node !== html && node.parentNode
          }
        , '>': function (node, contestant) {
            return node && node.parentNode == contestant.parentNode && node.parentNode
          }
        , '~': function (node) {
            return node && node.previousSibling
          }
        , '+': function (node, contestant, p1, p2) {
            if (!node) return false
            return (p1 = previous(node)) && (p2 = previous(contestant)) && p1 == p2 && p1
          }
        }
  
    function cache() {
      this.c = {}
    }
    cache.prototype = {
      g: function (k) {
        return this.c[k] || undefined
      }
    , s: function (k, v, r) {
        v = r ? new RegExp(v) : v
        return (this.c[k] = v)
      }
    }
  
    var classCache = new cache()
      , cleanCache = new cache()
      , attrCache = new cache()
      , tokenCache = new cache()
  
    function classRegex(c) {
      return classCache.g(c) || classCache.s(c, '(^|\\s+)' + c + '(\\s+|$)', 1)
    }
  
    // not quite as fast as inline loops in older browsers so don't use liberally
    function each(a, fn) {
      var i = 0, l = a.length
      for (; i < l; i++) fn(a[i])
    }
  
    function flatten(ar) {
      for (var r = [], i = 0, l = ar.length; i < l; ++i) arrayLike(ar[i]) ? (r = r.concat(ar[i])) : (r[r.length] = ar[i])
      return r
    }
  
    function arrayify(ar) {
      var i = 0, l = ar.length, r = []
      for (; i < l; i++) r[i] = ar[i]
      return r
    }
  
    function previous(n) {
      while (n = n.previousSibling) if (n[nodeType] == 1) break;
      return n
    }
  
    function q(query) {
      return query.match(chunker)
    }
  
    // called using `this` as element and arguments from regex group results.
    // given => div.hello[title="world"]:foo('bar')
    // div.hello[title="world"]:foo('bar'), div, .hello, [title="world"], title, =, world, :foo('bar'), foo, ('bar'), bar]
    function interpret(whole, tag, idsAndClasses, wholeAttribute, attribute, qualifier, value, wholePseudo, pseudo, wholePseudoVal, pseudoVal) {
      var i, m, k, o, classes
      if (this[nodeType] !== 1) return false
      if (tag && tag !== '*' && this[tagName] && this[tagName].toLowerCase() !== tag) return false
      if (idsAndClasses && (m = idsAndClasses.match(id)) && m[1] !== this.id) return false
      if (idsAndClasses && (classes = idsAndClasses.match(clas))) {
        for (i = classes.length; i--;) if (!classRegex(classes[i].slice(1)).test(this.className)) return false
      }
      if (pseudo && qwery.pseudos[pseudo] && !qwery.pseudos[pseudo](this, pseudoVal)) return false
      if (wholeAttribute && !value) { // select is just for existance of attrib
        o = this.attributes
        for (k in o) {
          if (Object.prototype.hasOwnProperty.call(o, k) && (o[k].name || k) == attribute) {
            return this
          }
        }
      }
      if (wholeAttribute && !checkAttr(qualifier, getAttr(this, attribute) || '', value)) {
        // select is for attrib equality
        return false
      }
      return this
    }
  
    function clean(s) {
      return cleanCache.g(s) || cleanCache.s(s, s.replace(specialChars, '\\$1'))
    }
  
    function checkAttr(qualify, actual, val) {
      switch (qualify) {
      case '=':
        return actual == val
      case '^=':
        return actual.match(attrCache.g('^=' + val) || attrCache.s('^=' + val, '^' + clean(val), 1))
      case '$=':
        return actual.match(attrCache.g('$=' + val) || attrCache.s('$=' + val, clean(val) + '$', 1))
      case '*=':
        return actual.match(attrCache.g(val) || attrCache.s(val, clean(val), 1))
      case '~=':
        return actual.match(attrCache.g('~=' + val) || attrCache.s('~=' + val, '(?:^|\\s+)' + clean(val) + '(?:\\s+|$)', 1))
      case '|=':
        return actual.match(attrCache.g('|=' + val) || attrCache.s('|=' + val, '^' + clean(val) + '(-|$)', 1))
      }
      return 0
    }
  
    // given a selector, first check for simple cases then collect all base candidate matches and filter
    function _qwery(selector, _root) {
      var r = [], ret = [], i, l, m, token, tag, els, intr, item, root = _root
        , tokens = tokenCache.g(selector) || tokenCache.s(selector, selector.split(tokenizr))
        , dividedTokens = selector.match(dividers)
  
      if (!tokens.length) return r
  
      token = (tokens = tokens.slice(0)).pop() // copy cached tokens, take the last one
      if (tokens.length && (m = tokens[tokens.length - 1].match(idOnly))) root = byId(_root, m[1])
      if (!root) return r
  
      intr = q(token)
      // collect base candidates to filter
      els = root !== _root && root[nodeType] !== 9 && dividedTokens && /^[+~]$/.test(dividedTokens[dividedTokens.length - 1]) ?
        function (r) {
          while (root = root.nextSibling) {
            root[nodeType] == 1 && (intr[1] ? intr[1] == root[tagName].toLowerCase() : 1) && (r[r.length] = root)
          }
          return r
        }([]) :
        root[byTag](intr[1] || '*')
      // filter elements according to the right-most part of the selector
      for (i = 0, l = els.length; i < l; i++) {
        if (item = interpret.apply(els[i], intr)) r[r.length] = item
      }
      if (!tokens.length) return r
  
      // filter further according to the rest of the selector (the left side)
      each(r, function(e) { if (ancestorMatch(e, tokens, dividedTokens)) ret[ret.length] = e })
      return ret
    }
  
    // compare element to a selector
    function is(el, selector, root) {
      if (isNode(selector)) return el == selector
      if (arrayLike(selector)) return !!~flatten(selector).indexOf(el) // if selector is an array, is el a member?
  
      var selectors = selector.split(','), tokens, dividedTokens
      while (selector = selectors.pop()) {
        tokens = tokenCache.g(selector) || tokenCache.s(selector, selector.split(tokenizr))
        dividedTokens = selector.match(dividers)
        tokens = tokens.slice(0) // copy array
        if (interpret.apply(el, q(tokens.pop())) && (!tokens.length || ancestorMatch(el, tokens, dividedTokens, root))) {
          return true
        }
      }
      return false
    }
  
    // given elements matching the right-most part of a selector, filter out any that don't match the rest
    function ancestorMatch(el, tokens, dividedTokens, root) {
      var cand
      // recursively work backwards through the tokens and up the dom, covering all options
      function crawl(e, i, p) {
        while (p = walker[dividedTokens[i]](p, e)) {
          if (isNode(p) && (interpret.apply(p, q(tokens[i])))) {
            if (i) {
              if (cand = crawl(p, i - 1, p)) return cand
            } else return p
          }
        }
      }
      return (cand = crawl(el, tokens.length - 1, el)) && (!root || isAncestor(cand, root))
    }
  
    function isNode(el, t) {
      return el && typeof el === 'object' && (t = el[nodeType]) && (t == 1 || t == 9)
    }
  
    function uniq(ar) {
      var a = [], i, j
      o: for (i = 0; i < ar.length; ++i) {
        for (j = 0; j < a.length; ++j) if (a[j] == ar[i]) continue o
        a[a.length] = ar[i]
      }
      return a
    }
  
    function arrayLike(o) {
      return (typeof o === 'object' && isFinite(o.length))
    }
  
    function normalizeRoot(root) {
      if (!root) return doc
      if (typeof root == 'string') return qwery(root)[0]
      if (!root[nodeType] && arrayLike(root)) return root[0]
      return root
    }
  
    function byId(root, id, el) {
      // if doc, query on it, else query the parent doc or if a detached fragment rewrite the query and run on the fragment
      return root[nodeType] === 9 ? root.getElementById(id) :
        root.ownerDocument &&
          (((el = root.ownerDocument.getElementById(id)) && isAncestor(el, root) && el) ||
            (!isAncestor(root, root.ownerDocument) && select('[id="' + id + '"]', root)[0]))
    }
  
    function qwery(selector, _root) {
      var m, el, root = normalizeRoot(_root)
  
      // easy, fast cases that we can dispatch with simple DOM calls
      if (!root || !selector) return []
      if (selector === window || isNode(selector)) {
        return !_root || (selector !== window && isNode(root) && isAncestor(selector, root)) ? [selector] : []
      }
      if (selector && arrayLike(selector)) return flatten(selector)
      if (m = selector.match(easy)) {
        if (m[1]) return (el = byId(root, m[1])) ? [el] : []
        if (m[2]) return arrayify(root[byTag](m[2]))
        if (hasByClass && m[3]) return arrayify(root[byClass](m[3]))
      }
  
      return select(selector, root)
    }
  
    // where the root is not document and a relationship selector is first we have to
    // do some awkward adjustments to get it to work, even with qSA
    function collectSelector(root, collector) {
      return function(s) {
        var oid, nid
        if (splittable.test(s)) {
          if (root[nodeType] !== 9) {
           // make sure the el has an id, rewrite the query, set root to doc and run it
           if (!(nid = oid = root.getAttribute('id'))) root.setAttribute('id', nid = '__qwerymeupscotty')
           s = '[id="' + nid + '"]' + s // avoid byId and allow us to match context element
           collector(root.parentNode || root, s, true)
           oid || root.removeAttribute('id')
          }
          return;
        }
        s.length && collector(root, s, false)
      }
    }
  
    var isAncestor = 'compareDocumentPosition' in html ?
      function (element, container) {
        return (container.compareDocumentPosition(element) & 16) == 16
      } : 'contains' in html ?
      function (element, container) {
        container = container[nodeType] === 9 || container == window ? html : container
        return container !== element && container.contains(element)
      } :
      function (element, container) {
        while (element = element.parentNode) if (element === container) return 1
        return 0
      }
    , getAttr = function() {
        // detect buggy IE src/href getAttribute() call
        var e = doc.createElement('p')
        return ((e.innerHTML = '<a href="#x">x</a>') && e.firstChild.getAttribute('href') != '#x') ?
          function(e, a) {
            return a === 'class' ? e.className : (a === 'href' || a === 'src') ?
              e.getAttribute(a, 2) : e.getAttribute(a)
          } :
          function(e, a) { return e.getAttribute(a) }
     }()
    , hasByClass = !!doc[byClass]
      // has native qSA support
    , hasQSA = doc.querySelector && doc[qSA]
      // use native qSA
    , selectQSA = function (selector, root) {
        var result = [], ss, e
        try {
          if (root[nodeType] === 9 || !splittable.test(selector)) {
            // most work is done right here, defer to qSA
            return arrayify(root[qSA](selector))
          }
          // special case where we need the services of `collectSelector()`
          each(ss = selector.split(','), collectSelector(root, function(ctx, s) {
            e = ctx[qSA](s)
            if (e.length == 1) result[result.length] = e.item(0)
            else if (e.length) result = result.concat(arrayify(e))
          }))
          return ss.length > 1 && result.length > 1 ? uniq(result) : result
        } catch(ex) { }
        return selectNonNative(selector, root)
      }
      // no native selector support
    , selectNonNative = function (selector, root) {
        var result = [], items, m, i, l, r, ss
        selector = selector.replace(normalizr, '$1')
        if (m = selector.match(tagAndOrClass)) {
          r = classRegex(m[2])
          items = root[byTag](m[1] || '*')
          for (i = 0, l = items.length; i < l; i++) {
            if (r.test(items[i].className)) result[result.length] = items[i]
          }
          return result
        }
        // more complex selector, get `_qwery()` to do the work for us
        each(ss = selector.split(','), collectSelector(root, function(ctx, s, rewrite) {
          r = _qwery(s, ctx)
          for (i = 0, l = r.length; i < l; i++) {
            if (ctx[nodeType] === 9 || rewrite || isAncestor(r[i], root)) result[result.length] = r[i]
          }
        }))
        return ss.length > 1 && result.length > 1 ? uniq(result) : result
      }
    , configure = function (options) {
        // configNativeQSA: use fully-internal selector or native qSA where present
        if (typeof options[useNativeQSA] !== 'undefined')
          select = !options[useNativeQSA] ? selectNonNative : hasQSA ? selectQSA : selectNonNative
      }
  
    configure({ useNativeQSA: true })
  
    qwery.configure = configure
    qwery.uniq = uniq
    qwery.is = is
    qwery.pseudos = {}
  
    return qwery
  }, this);
  

  provide("qwery", module.exports);

  (function ($) {
    var q = function () {
      var r
      try {
        r = require('qwery')
      } catch (ex) {
        r = require('qwery-mobile')
      } finally {
        return r
      }
    }()
  
    $.pseudos = q.pseudos
  
    $._select = function (s, r) {
      // detect if sibling module 'bonzo' is available at run-time
      // rather than load-time since technically it's not a dependency and
      // can be loaded in any order
      // hence the lazy function re-definition
      return ($._select = (function () {
        var b
        if (typeof $.create == 'function') return function (s, r) {
          return /^\s*</.test(s) ? $.create(s, r) : q(s, r)
        }
        try {
          b = require('bonzo')
          return function (s, r) {
            return /^\s*</.test(s) ? b.create(s, r) : q(s, r)
          }
        } catch (e) { }
        return q
      })())(s, r)
    }
  
    $.ender({
        find: function (s) {
          var r = [], i, l, j, k, els
          for (i = 0, l = this.length; i < l; i++) {
            els = q(s, this[i])
            for (j = 0, k = els.length; j < k; j++) r.push(els[j])
          }
          return $(q.uniq(r))
        }
      , and: function (s) {
          var plus = $(s)
          for (var i = this.length, j = 0, l = this.length + plus.length; i < l; i++, j++) {
            this[i] = plus[j]
          }
          this.length += plus.length
          return this
        }
      , is: function(s, r) {
          var i, l
          for (i = 0, l = this.length; i < l; i++) {
            if (q.is(this[i], s, r)) {
              return true
            }
          }
          return false
        }
    }, true)
  }(ender));
  

}());

(function () {

  var module = { exports: {} }, exports = module.exports;

  /*!
    * Reqwest! A general purpose XHR connection manager
    * (c) Dustin Diaz 2011
    * https://github.com/ded/reqwest
    * license MIT
    */
  !function (name, definition) {
    if (typeof module != 'undefined') module.exports = definition()
    else if (typeof define == 'function' && define.amd) define(name, definition)
    else this[name] = definition()
  }('reqwest', function () {
  
    var win = window
      , doc = document
      , twoHundo = /^20\d$/
      , byTag = 'getElementsByTagName'
      , readyState = 'readyState'
      , contentType = 'Content-Type'
      , requestedWith = 'X-Requested-With'
      , head = doc[byTag]('head')[0]
      , uniqid = 0
      , lastValue // data stored by the most recent JSONP callback
      , xmlHttpRequest = 'XMLHttpRequest'
      , isArray = typeof Array.isArray == 'function' ? Array.isArray : function (a) {
          return a instanceof Array
        }
      , defaultHeaders = {
            contentType: 'application/x-www-form-urlencoded'
          , accept: {
                '*':  'text/javascript, text/html, application/xml, text/xml, */*'
              , xml:  'application/xml, text/xml'
              , html: 'text/html'
              , text: 'text/plain'
              , json: 'application/json, text/javascript'
              , js:   'application/javascript, text/javascript'
            }
          , requestedWith: xmlHttpRequest
        }
      , xhr = win[xmlHttpRequest] ?
          function () {
            return new XMLHttpRequest()
          } :
          function () {
            return new ActiveXObject('Microsoft.XMLHTTP')
          }
  
    function handleReadyState(o, success, error) {
      return function () {
        if (o && o[readyState] == 4) {
          if (twoHundo.test(o.status)) {
            success(o)
          } else {
            error(o)
          }
        }
      }
    }
  
    function setHeaders(http, o) {
      var headers = o.headers || {}, h
      headers.Accept = headers.Accept || defaultHeaders.accept[o.type] || defaultHeaders.accept['*']
      // breaks cross-origin requests with legacy browsers
      if (!o.crossOrigin && !headers[requestedWith]) headers[requestedWith] = defaultHeaders.requestedWith
      if (!headers[contentType]) headers[contentType] = o.contentType || defaultHeaders.contentType
      for (h in headers) {
        headers.hasOwnProperty(h) && http.setRequestHeader(h, headers[h])
      }
    }
  
    function generalCallback(data) {
      lastValue = data
    }
  
    function urlappend(url, s) {
      return url + (/\?/.test(url) ? '&' : '?') + s
    }
  
    function handleJsonp(o, fn, err, url) {
      var reqId = uniqid++
        , cbkey = o.jsonpCallback || 'callback' // the 'callback' key
        , cbval = o.jsonpCallbackName || ('reqwest_' + reqId) // the 'callback' value
        , cbreg = new RegExp('((^|\\?|&)' + cbkey + ')=([^&]+)')
        , match = url.match(cbreg)
        , script = doc.createElement('script')
        , loaded = 0
  
      if (match) {
        if (match[3] === '?') {
          url = url.replace(cbreg, '$1=' + cbval) // wildcard callback func name
        } else {
          cbval = match[3] // provided callback func name
        }
      } else {
        url = urlappend(url, cbkey + '=' + cbval) // no callback details, add 'em
      }
  
      win[cbval] = generalCallback
  
      script.type = 'text/javascript'
      script.src = url
      script.async = true
      if (typeof script.onreadystatechange !== 'undefined') {
          // need this for IE due to out-of-order onreadystatechange(), binding script
          // execution to an event listener gives us control over when the script
          // is executed. See http://jaubourg.net/2010/07/loading-script-as-onclick-handler-of.html
          script.event = 'onclick'
          script.htmlFor = script.id = '_reqwest_' + reqId
      }
  
      script.onload = script.onreadystatechange = function () {
        if ((script[readyState] && script[readyState] !== 'complete' && script[readyState] !== 'loaded') || loaded) {
          return false
        }
        script.onload = script.onreadystatechange = null
        script.onclick && script.onclick()
        // Call the user callback with the last value stored and clean up values and scripts.
        o.success && o.success(lastValue)
        lastValue = undefined
        head.removeChild(script)
        loaded = 1
      }
  
      // Add the script to the DOM head
      head.appendChild(script)
    }
  
    function getRequest(o, fn, err) {
      var method = (o.method || 'GET').toUpperCase()
        , url = typeof o === 'string' ? o : o.url
        // convert non-string objects to query-string form unless o.processData is false
        , data = (o.processData !== false && o.data && typeof o.data !== 'string')
          ? reqwest.toQueryString(o.data)
          : (o.data || null)
        , http
  
      // if we're working on a GET request and we have data then we should append
      // query string to end of URL and not post data
      if ((o.type == 'jsonp' || method == 'GET') && data) {
        url = urlappend(url, data)
        data = null
      }
  
      if (o.type == 'jsonp') return handleJsonp(o, fn, err, url)
  
      http = xhr()
      http.open(method, url, true)
      setHeaders(http, o)
      http.onreadystatechange = handleReadyState(http, fn, err)
      o.before && o.before(http)
      http.send(data)
      return http
    }
  
    function Reqwest(o, fn) {
      this.o = o
      this.fn = fn
      init.apply(this, arguments)
    }
  
    function setType(url) {
      var m = url.match(/\.(json|jsonp|html|xml)(\?|$)/)
      return m ? m[1] : 'js'
    }
  
    function init(o, fn) {
      this.url = typeof o == 'string' ? o : o.url
      this.timeout = null
      var type = o.type || setType(this.url)
        , self = this
      fn = fn || function () {}
  
      if (o.timeout) {
        this.timeout = setTimeout(function () {
          self.abort()
        }, o.timeout)
      }
  
      function complete(resp) {
        o.timeout && clearTimeout(self.timeout)
        self.timeout = null
        o.complete && o.complete(resp)
      }
  
      function success(resp) {
        var r = resp.responseText
        if (r) {
          switch (type) {
          case 'json':
            try {
              resp = win.JSON ? win.JSON.parse(r) : eval('(' + r + ')')
            } catch (err) {
              return error(resp, 'Could not parse JSON in response', err)
            }
            break;
          case 'js':
            resp = eval(r)
            break;
          case 'html':
            resp = r
            break;
          }
        }
  
        fn(resp)
        o.success && o.success(resp)
  
        complete(resp)
      }
  
      function error(resp, msg, t) {
        o.error && o.error(resp, msg, t)
        complete(resp)
      }
  
      this.request = getRequest(o, success, error)
    }
  
    Reqwest.prototype = {
      abort: function () {
        this.request.abort()
      }
  
    , retry: function () {
        init.call(this, this.o, this.fn)
      }
    }
  
    function reqwest(o, fn) {
      return new Reqwest(o, fn)
    }
  
    // normalize newline variants according to spec -> CRLF
    function normalize(s) {
      return s ? s.replace(/\r?\n/g, '\r\n') : ''
    }
  
    function serial(el, cb) {
      var n = el.name
        , t = el.tagName.toLowerCase()
        , optCb = function(o) {
            // IE gives value="" even where there is no value attribute
            // 'specified' ref: http://www.w3.org/TR/DOM-Level-3-Core/core.html#ID-862529273
            if (o && !o.disabled)
              cb(n, normalize(o.attributes.value && o.attributes.value.specified ? o.value : o.text))
          }
  
      // don't serialize elements that are disabled or without a name
      if (el.disabled || !n) return;
  
      switch (t) {
      case 'input':
        if (!/reset|button|image|file/i.test(el.type)) {
          var ch = /checkbox/i.test(el.type)
            , ra = /radio/i.test(el.type)
            , val = el.value;
          // WebKit gives us "" instead of "on" if a checkbox has no value, so correct it here
          (!(ch || ra) || el.checked) && cb(n, normalize(ch && val === '' ? 'on' : val))
        }
        break;
      case 'textarea':
        cb(n, normalize(el.value))
        break;
      case 'select':
        if (el.type.toLowerCase() === 'select-one') {
          optCb(el.selectedIndex >= 0 ? el.options[el.selectedIndex] : null)
        } else {
          for (var i = 0; el.length && i < el.length; i++) {
            el.options[i].selected && optCb(el.options[i])
          }
        }
        break;
      }
    }
  
    // collect up all form elements found from the passed argument elements all
    // the way down to child elements; pass a '<form>' or form fields.
    // called with 'this'=callback to use for serial() on each element
    function eachFormElement() {
      var cb = this
        , e, i, j
        , serializeSubtags = function(e, tags) {
          for (var i = 0; i < tags.length; i++) {
            var fa = e[byTag](tags[i])
            for (j = 0; j < fa.length; j++) serial(fa[j], cb)
          }
        }
  
      for (i = 0; i < arguments.length; i++) {
        e = arguments[i]
        if (/input|select|textarea/i.test(e.tagName)) serial(e, cb)
        serializeSubtags(e, [ 'input', 'select', 'textarea' ])
      }
    }
  
    // standard query string style serialization
    function serializeQueryString() {
      return reqwest.toQueryString(reqwest.serializeArray.apply(null, arguments))
    }
  
    // { 'name': 'value', ... } style serialization
    function serializeHash() {
      var hash = {}
      eachFormElement.apply(function (name, value) {
        if (name in hash) {
          hash[name] && !isArray(hash[name]) && (hash[name] = [hash[name]])
          hash[name].push(value)
        } else hash[name] = value
      }, arguments)
      return hash
    }
  
    // [ { name: 'name', value: 'value' }, ... ] style serialization
    reqwest.serializeArray = function () {
      var arr = []
      eachFormElement.apply(function(name, value) {
        arr.push({name: name, value: value})
      }, arguments)
      return arr
    }
  
    reqwest.serialize = function () {
      if (arguments.length === 0) return ''
      var opt, fn
        , args = Array.prototype.slice.call(arguments, 0)
  
      opt = args.pop()
      opt && opt.nodeType && args.push(opt) && (opt = null)
      opt && (opt = opt.type)
  
      if (opt == 'map') fn = serializeHash
      else if (opt == 'array') fn = reqwest.serializeArray
      else fn = serializeQueryString
  
      return fn.apply(null, args)
    }
  
    reqwest.toQueryString = function (o) {
      var qs = '', i
        , enc = encodeURIComponent
        , push = function (k, v) {
            qs += enc(k) + '=' + enc(v) + '&'
          }
  
      if (isArray(o)) {
        for (i = 0; o && i < o.length; i++) push(o[i].name, o[i].value)
      } else {
        for (var k in o) {
          if (!Object.hasOwnProperty.call(o, k)) continue;
          var v = o[k]
          if (isArray(v)) {
            for (i = 0; i < v.length; i++) push(k, v[i])
          } else push(k, o[k])
        }
      }
  
      // spaces should be + according to spec
      return qs.replace(/&$/, '').replace(/%20/g,'+')
    }
  
    // jQuery and Zepto compatibility, differences can be remapped here so you can call
    // .ajax.compat(options, callback)
    reqwest.compat = function (o, fn) {
      if (o) {
        o.type && (o.method = o.type) && delete o.type
        o.dataType && (o.type = o.dataType)
        o.jsonpCallback && (o.jsonpCallbackName = o.jsonpCallback) && delete o.jsonpCallback
        o.jsonp && (o.jsonpCallback = o.jsonp)
      }
      return new Reqwest(o, fn)
    }
  
    return reqwest
  })
  

  provide("reqwest", module.exports);

  !function ($) {
    var r = require('reqwest')
      , integrate = function(method) {
          return function() {
            var args = Array.prototype.slice.call(arguments, 0)
              , i = (this && this.length) || 0
            while (i--) args.unshift(this[i])
            return r[method].apply(null, args)
          }
        }
      , s = integrate('serialize')
      , sa = integrate('serializeArray')
  
    $.ender({
        ajax: r
      , serialize: r.serialize
      , serializeArray: r.serializeArray
      , toQueryString: r.toQueryString
    })
  
    $.ender({
        serialize: s
      , serializeArray: sa
    }, true)
  }(ender);
  

}());

(function () {

  var module = { exports: {} }, exports = module.exports;

  // Generated by CoffeeScript 1.3.3
  /*
  #
  # More info at [www.opentip.org](http://www.opentip.org)
  # 
  # Copyright (c) 2012, Matias Meno  
  # Graphics by Tjandra Mayerhold
  # 
  # Permission is hereby granted, free of charge, to any person obtaining a copy
  # of this software and associated documentation files (the "Software"), to deal
  # in the Software without restriction, including without limitation the rights
  # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  # copies of the Software, and to permit persons to whom the Software is
  # furnished to do so, subject to the following conditions:
  # 
  # The above copyright notice and this permission notice shall be included in
  # all copies or substantial portions of the Software.
  # 
  # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  # THE SOFTWARE.
  #
  */
  
  var Opentip, firstAdapter, i, position, vendors, _i, _len, _ref,
    __slice = [].slice,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },
    __hasProp = {}.hasOwnProperty;
  
  Opentip = (function() {
  
    Opentip.prototype.STICKS_OUT_TOP = 1;
  
    Opentip.prototype.STICKS_OUT_BOTTOM = 2;
  
    Opentip.prototype.STICKS_OUT_LEFT = 1;
  
    Opentip.prototype.STICKS_OUT_RIGHT = 2;
  
    Opentip.prototype["class"] = {
      container: "opentip-container",
      opentip: "opentip",
      content: "content",
      loadingIndicator: "loading-indicator",
      close: "close",
      goingToHide: "going-to-hide",
      hidden: "hidden",
      hiding: "hiding",
      goingToShow: "going-to-show",
      showing: "showing",
      visible: "visible",
      loading: "loading",
      ajaxError: "ajax-error",
      fixed: "fixed",
      showEffectPrefix: "show-effect-",
      hideEffectPrefix: "hide-effect-",
      stylePrefix: "style-"
    };
  
    function Opentip(element, content, title, options) {
      var elementsOpentips, hideTrigger, optionSources, prop, styleOptions, _i, _len, _ref, _ref1,
        _this = this;
      this.id = ++Opentip.lastId;
      this.debug("Creating Opentip.");
      this.adapter = Opentip.adapter;
      elementsOpentips = this.adapter.data(element, "opentips") || [];
      elementsOpentips.push(this);
      this.adapter.data(element, "opentips", elementsOpentips);
      this.triggerElement = this.adapter.wrap(element);
      if (this.triggerElement.length > 1) {
        throw new Error("You can't call Opentip on multiple elements.");
      }
      if (this.triggerElement.length < 1) {
        throw new Error("Invalid element.");
      }
      this.loaded = false;
      this.loading = false;
      this.visible = false;
      this.waitingToShow = false;
      this.waitingToHide = false;
      this.currentPosition = {
        left: 0,
        top: 0
      };
      this.dimensions = {
        width: 100,
        height: 50
      };
      this.content = "";
      this.redraw = true;
      this.currentObservers = {
        showing: false,
        visible: false,
        hiding: false,
        hidden: false
      };
      options = this.adapter.clone(options);
      if (typeof content === "object") {
        options = content;
        content = title = void 0;
      } else if (typeof title === "object") {
        options = title;
        title = void 0;
      }
      if (title != null) {
        options.title = title;
      }
      if (content != null) {
        this.setContent(content);
      }
      if (!options.style) {
        options.style = Opentip.defaultStyle;
      }
      styleOptions = this.adapter.extend({}, Opentip.styles.standard);
      optionSources = [];
      optionSources.push(Opentip.styles.standard);
      if (options.style !== "standard") {
        optionSources.push(Opentip.styles[options.style]);
      }
      optionSources.push(options);
      options = (_ref = this.adapter).extend.apply(_ref, [{}].concat(__slice.call(optionSources)));
      options.hideTriggers = (function() {
        var _i, _len, _ref1, _results;
        _ref1 = options.hideTriggers;
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          hideTrigger = _ref1[_i];
          _results.push(hideTrigger);
        }
        return _results;
      })();
      if (options.hideTrigger) {
        options.hideTriggers.push(options.hideTrigger);
      }
      _ref1 = ["tipJoint", "targetJoint", "stem"];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        prop = _ref1[_i];
        if (options[prop] && typeof options[prop] === "string") {
          options[prop] = new Opentip.Joint(options[prop]);
        }
      }
      if (options.ajax && (options.ajax === true || !options.ajax)) {
        if (this.adapter.tagName(this.triggerElement) === "A") {
          options.ajax = this.adapter.attr(this.triggerElement, "href");
        } else {
          options.ajax = false;
        }
      }
      if (options.showOn === "click" && this.adapter.tagName(this.triggerElement) === "A") {
        this.adapter.observe(this.triggerElement, "click", function(e) {
          e.preventDefault();
          e.stopPropagation();
          return e.stopped = true;
        });
      }
      if (options.target) {
        options.fixed = true;
      }
      if (options.stem === true) {
        options.stem = new Opentip.Joint(options.tipJoint);
      }
      if (options.target === true) {
        options.target = this.triggerElement;
      } else if (options.target) {
        options.target = this.adapter.wrap(options.target);
      }
      this.currentStem = options.stem;
      if (options.delay == null) {
        options.delay = options.showOn === "mouseover" ? 0.2 : 0;
      }
      if (options.targetJoint == null) {
        options.targetJoint = new Opentip.Joint(options.tipJoint).flip();
      }
      this.showTriggersWhenHidden = [];
      this.showTriggersWhenVisible = [];
      this.hideTriggers = [];
      if (options.showOn && options.showOn !== "creation") {
        this.showTriggersWhenHidden.push({
          element: this.triggerElement,
          event: options.showOn
        });
      }
      this.options = options;
      this.adapter.domReady(function() {
        return _this._init();
      });
    }
  
    Opentip.prototype._init = function() {
      var hideOn, hideTrigger, hideTriggerElement, i, methodToBind, _i, _j, _len, _len1, _ref, _ref1,
        _this = this;
      this._buildContainer();
      _ref = this.options.hideTriggers;
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        hideTrigger = _ref[i];
        hideTriggerElement = null;
        hideOn = this.options.hideOn instanceof Array ? this.options.hideOn[i] : this.options.hideOn;
        if (typeof hideTrigger === "string") {
          switch (hideTrigger) {
            case "trigger":
              hideOn = hideOn || "mouseout";
              hideTriggerElement = this.triggerElement;
              break;
            case "tip":
              hideOn = hideOn || "mouseover";
              hideTriggerElement = this.container;
              break;
            case "target":
              hideOn = hideOn || "mouseover";
              hideTriggerElement = this.options.target;
              break;
            case "closeButton":
              break;
            default:
              throw new Error("Unknown hide trigger: " + hideTrigger + ".");
          }
        } else {
          hideOn = hideOn || "mouseover";
          hideTriggerElement = this.adapter.wrap(hideTrigger);
        }
        if (hideTriggerElement) {
          this.hideTriggers.push({
            element: hideTriggerElement,
            event: hideOn
          });
          if (hideOn === "mouseout") {
            this.showTriggersWhenVisible.push({
              element: hideTriggerElement,
              event: "mouseover"
            });
          }
        }
      }
      this.bound = {};
      _ref1 = ["prepareToShow", "prepareToHide", "show", "hide", "reposition"];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        methodToBind = _ref1[_j];
        this.bound[methodToBind] = (function(methodToBind) {
          return function() {
            return _this[methodToBind].apply(_this, arguments);
          };
        })(methodToBind);
      }
      this.activate();
      if (this.options.showOn === "creation") {
        return this.prepareToShow();
      }
    };
  
    Opentip.prototype._buildContainer = function() {
      this.container = this.adapter.create("<div id=\"opentip-" + this.id + "\" class=\"" + this["class"].container + " " + this["class"].hidden + " " + this["class"].stylePrefix + this.options.className + "\"></div>");
      this.adapter.css(this.container, {
        position: "absolute"
      });
      if (this.options.ajax) {
        this.adapter.addClass(this.container, this["class"].loading);
      }
      if (this.options.fixed) {
        this.adapter.addClass(this.container, this["class"].fixed);
      }
      if (this.options.showEffect) {
        this.adapter.addClass(this.container, "" + this["class"].showEffectPrefix + this.options.showEffect);
      }
      if (this.options.hideEffect) {
        return this.adapter.addClass(this.container, "" + this["class"].hideEffectPrefix + this.options.hideEffect);
      }
    };
  
    Opentip.prototype._buildElements = function() {
      var headerElement, titleElement;
      this.tooltipElement = this.adapter.create("<div class=\"" + this["class"].opentip + "\"><header></header><div class=\"" + this["class"].content + "\"></div></div>");
      this.backgroundCanvas = this.adapter.create("<canvas style=\"position: absolute;\"></canvas>");
      headerElement = this.adapter.find(this.tooltipElement, "header");
      if (this.options.title) {
        titleElement = this.adapter.create("<h1></h1>");
        this.adapter.update(titleElement, this.options.title, this.options.escapeTitle);
        this.adapter.append(headerElement, titleElement);
      }
      if (this.options.ajax) {
        this.adapter.append(this.tooltipElement, this.adapter.create("<div class=\"" + this["class"].loadingIndicator + "\"><span>Loading...</span></div>"));
      }
      if (__indexOf.call(this.options.hideTriggers, "closeButton") >= 0) {
        this.closeButtonElement = this.adapter.create("<a href=\"javascript:undefined;\" class=\"" + this["class"].close + "\"><span>Close</span></a>");
        this.adapter.append(headerElement, this.closeButtonElement);
      }
      this.adapter.append(this.container, this.backgroundCanvas);
      this.adapter.append(this.container, this.tooltipElement);
      return this.adapter.append(document.body, this.container);
    };
  
    Opentip.prototype.setContent = function(content) {
      this.content = content;
      if (this.visible) {
        return this._updateElementContent();
      }
    };
  
    Opentip.prototype._updateElementContent = function() {
      var contentDiv;
      contentDiv = this.adapter.find(this.container, ".content");
      if (contentDiv != null) {
        if (typeof this.content === "function") {
          this.debug("Executing content function.");
          this.content = this.content(this);
        }
        this.adapter.update(contentDiv, this.content, this.options.escapeContent);
      }
      this._storeAndLockDimensions();
      return this.reposition();
    };
  
    Opentip.prototype._storeAndLockDimensions = function() {
      var prevDimension;
      prevDimension = this.dimensions;
      this.adapter.css(this.container, {
        width: "auto",
        left: "0px",
        top: "0px"
      });
      this.dimensions = this.adapter.dimensions(this.container);
      this.dimensions.width += 1;
      this.adapter.css(this.container, {
        width: "" + this.dimensions.width + "px",
        top: "" + this.currentPosition.top + "px",
        left: "" + this.currentPosition.left + "px"
      });
      if (!this._dimensionsEqual(this.dimensions, prevDimension)) {
        this.redraw = true;
        return this._draw();
      }
    };
  
    Opentip.prototype.activate = function() {
      return this._setupObservers("-showing", "-visible", "hidden", "hiding");
    };
  
    Opentip.prototype.deactivate = function() {
      this.debug("Deactivating tooltip.");
      return this.hide();
    };
  
    Opentip.prototype._setupObservers = function() {
      var observeOrStop, removeObserver, state, states, trigger, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2,
        _this = this;
      states = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      for (_i = 0, _len = states.length; _i < _len; _i++) {
        state = states[_i];
        removeObserver = false;
        if (state.charAt(0) === "-") {
          removeObserver = true;
          state = state.substr(1);
        }
        if (this.currentObservers[state] === !removeObserver) {
          continue;
        }
        this.currentObservers[state] = !removeObserver;
        observeOrStop = function() {
          var args, _ref, _ref1;
          args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
          if (removeObserver) {
            return (_ref = _this.adapter).stopObserving.apply(_ref, args);
          } else {
            return (_ref1 = _this.adapter).observe.apply(_ref1, args);
          }
        };
        switch (state) {
          case "showing":
            _ref = this.hideTriggers;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              trigger = _ref[_j];
              observeOrStop(trigger.element, trigger.event, this.bound.prepareToHide);
            }
            observeOrStop((document.onresize != null ? document : window), "resize", this.bound.reposition);
            observeOrStop(window, "scroll", this.bound.reposition);
            break;
          case "visible":
            _ref1 = this.showTriggersWhenVisible;
            for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
              trigger = _ref1[_k];
              observeOrStop(trigger.element, trigger.event, this.bound.prepareToShow);
            }
            break;
          case "hiding":
            _ref2 = this.showTriggersWhenHidden;
            for (_l = 0, _len3 = _ref2.length; _l < _len3; _l++) {
              trigger = _ref2[_l];
              observeOrStop(trigger.element, trigger.event, this.bound.prepareToShow);
            }
            break;
          case "hidden":
            break;
          default:
            throw new Error("Unknown state: " + state);
        }
      }
      return null;
    };
  
    Opentip.prototype.prepareToShow = function() {
      this._abortHiding();
      if (this.visible) {
        return;
      }
      this.debug("Showing in " + this.options.delay + "s.");
      if (this.options.group) {
        Opentip._abortShowingGroup(this.options.group);
      }
      this.preparingToShow = true;
      this._setupObservers("-hidden", "-hiding", "showing");
      this._followMousePosition();
      this.reposition();
      return this._showTimeoutId = this.setTimeout(this.bound.show, this.options.delay || 0);
    };
  
    Opentip.prototype.show = function() {
      var _this = this;
      this._clearTimeouts();
      if (this.visible) {
        return;
      }
      if (!this._triggerElementExists()) {
        return this.deactivate();
      }
      this.debug("Showing now.");
      if (this.options.group) {
        Opentip._hideGroup(this.options.group);
      }
      this.visible = true;
      this.preparingToShow = false;
      if (this.tooltipElement == null) {
        this._buildElements();
      }
      this._updateElementContent();
      if (this.options.ajax && (!this.loaded || !this.options.ajaxCache)) {
        this._loadAjax();
      }
      this._searchAndActivateCloseButtons();
      this._startEnsureTriggerElement();
      this.adapter.css(this.container, {
        zIndex: Opentip.lastZIndex++
      });
      this._setupObservers("-hidden", "-hiding", "showing", "visible");
      this.reposition();
      this.adapter.removeClass(this.container, this["class"].hiding);
      this.adapter.removeClass(this.container, this["class"].hidden);
      this.adapter.addClass(this.container, this["class"].goingToShow);
      this.setCss3Style(this.container, {
        transitionDuration: "0s"
      });
      this.defer(function() {
        var delay;
        _this.adapter.removeClass(_this.container, _this["class"].goingToShow);
        _this.adapter.addClass(_this.container, _this["class"].showing);
        delay = 0;
        if (_this.options.showEffect && _this.options.showEffectDuration) {
          delay = _this.options.showEffectDuration;
        }
        _this.setCss3Style(_this.container, {
          transitionDuration: "" + delay + "s"
        });
        _this._visibilityStateTimeoutId = _this.setTimeout(function() {
          _this.adapter.removeClass(_this.container, _this["class"].showing);
          return _this.adapter.addClass(_this.container, _this["class"].visible);
        }, delay);
        return _this._activateFirstInput();
      });
      return this._draw();
    };
  
    Opentip.prototype._abortShowing = function() {
      if (this.preparingToShow) {
        this.debug("Aborting showing.");
        this._clearTimeouts();
        this._stopFollowingMousePosition();
        this.preparingToShow = false;
        return this._setupObservers("-showing", "-visible", "hiding", "hidden");
      }
    };
  
    Opentip.prototype.prepareToHide = function() {
      this._abortShowing();
      if (!this.visible) {
        return;
      }
      this.debug("Hiding in " + this.options.hideDelay + "s");
      this.preparingToHide = true;
      this._setupObservers("-showing", "-visible", "-hidden", "hiding");
      return this._hideTimeoutId = this.setTimeout(this.bound.hide, this.options.hideDelay);
    };
  
    Opentip.prototype.hide = function() {
      var _this = this;
      this._clearTimeouts();
      if (!this.visible) {
        return;
      }
      this.debug("Hiding!");
      this.visible = false;
      this.preparingToHide = false;
      this._stopEnsureTriggerElement();
      this._setupObservers("-showing", "-visible", "hiding", "hidden");
      if (!this.options.fixed) {
        this._stopFollowingMousePosition();
      }
      this.adapter.removeClass(this.container, this["class"].visible);
      this.adapter.removeClass(this.container, this["class"].showing);
      this.adapter.addClass(this.container, this["class"].goingToHide);
      this.setCss3Style(this.container, {
        transitionDuration: "0s"
      });
      return this.defer(function() {
        var hideDelay;
        _this.adapter.removeClass(_this.container, _this["class"].goingToHide);
        _this.adapter.addClass(_this.container, _this["class"].hiding);
        hideDelay = 0;
        if (_this.options.hideEffect && _this.options.hideEffectDuration) {
          hideDelay = _this.options.hideEffectDuration;
        }
        _this.setCss3Style(_this.container, {
          transitionDuration: "" + hideDelay + "s"
        });
        return _this._visibilityStateTimeoutId = _this.setTimeout(function() {
          _this.adapter.removeClass(_this.container, _this["class"].hiding);
          _this.adapter.addClass(_this.container, _this["class"].hidden);
          return _this.setCss3Style(_this.container, {
            transitionDuration: "0s"
          });
        }, hideDelay);
      });
    };
  
    Opentip.prototype._abortHiding = function() {
      if (this.preparingToHide) {
        this.debug("Aborting hiding.");
        this._clearTimeouts();
        this.preparingToHide = false;
        return this._setupObservers("-hiding", "showing", "visible");
      }
    };
  
    Opentip.prototype.reposition = function(e) {
      var position, stem, _ref,
        _this = this;
      if (e == null) {
        e = this.lastEvent;
      }
      position = this.getPosition(e);
      if (position == null) {
        return;
      }
      stem = this.options.stem;
      if (this.options.containInViewport) {
        _ref = this._ensureViewportContainment(e, position), position = _ref.position, stem = _ref.stem;
      }
      if (this._positionsEqual(position, this.currentPosition)) {
        return;
      }
      if (!(!this.options.stem || stem.eql(this.currentStem))) {
        this.redraw = true;
      }
      this.currentPosition = position;
      this.currentStem = stem;
      this._draw();
      this.adapter.css(this.container, {
        left: "" + position.left + "px",
        top: "" + position.top + "px"
      });
      return this.defer(function() {
        var rawContainer, redrawFix;
        rawContainer = _this.adapter.unwrap(_this.container);
        rawContainer.style.visibility = "hidden";
        redrawFix = rawContainer.offsetHeight;
        return rawContainer.style.visibility = "visible";
      });
    };
  
    Opentip.prototype.getPosition = function(e, tipJoint, targetJoint, stem) {
      var additionalHorizontal, additionalVertical, mousePosition, offsetDistance, position, stemLength, targetDimensions, targetPosition, unwrappedTarget, _ref;
      if (tipJoint == null) {
        tipJoint = this.options.tipJoint;
      }
      if (targetJoint == null) {
        targetJoint = this.options.targetJoint;
      }
      position = {};
      if (this.options.target) {
        targetPosition = this.adapter.offset(this.options.target);
        targetDimensions = this.adapter.dimensions(this.options.target);
        position = targetPosition;
        if (targetJoint.right) {
          unwrappedTarget = this.adapter.unwrap(this.options.target);
          if (unwrappedTarget.getBoundingClientRect != null) {
            position.left = unwrappedTarget.getBoundingClientRect().right + ((_ref = window.pageXOffset) != null ? _ref : document.body.scrollLeft);
          } else {
            position.left += targetDimensions.width;
          }
        } else if (targetJoint.center) {
          position.left += Math.round(targetDimensions.width / 2);
        }
        if (targetJoint.bottom) {
          position.top += targetDimensions.height;
        } else if (targetJoint.middle) {
          position.top += Math.round(targetDimensions.height / 2);
        }
        if (this.options.borderWidth) {
          if (this.options.tipJoint.left) {
            position.left += this.options.borderWidth;
          }
          if (this.options.tipJoint.right) {
            position.left -= this.options.borderWidth;
          }
          if (this.options.tipJoint.top) {
            position.top += this.options.borderWidth;
          } else if (this.options.tipJoint.bottom) {
            position.top -= this.options.borderWidth;
          }
        }
      } else {
        if (e != null) {
          this.lastEvent = e;
        }
        mousePosition = this.adapter.mousePosition(e);
        if (mousePosition == null) {
          return;
        }
        position = {
          top: mousePosition.y,
          left: mousePosition.x
        };
      }
      if (this.options.autoOffset) {
        stemLength = this.options.stem ? this.options.stemLength : 0;
        offsetDistance = stemLength && this.options.fixed ? 2 : 10;
        additionalHorizontal = tipJoint.middle && !this.options.fixed ? 15 : 0;
        additionalVertical = tipJoint.center && !this.options.fixed ? 15 : 0;
        if (tipJoint.right) {
          position.left -= offsetDistance + additionalHorizontal;
        } else if (tipJoint.left) {
          position.left += offsetDistance + additionalHorizontal;
        }
        if (tipJoint.bottom) {
          position.top -= offsetDistance + additionalVertical;
        } else if (tipJoint.top) {
          position.top += offsetDistance + additionalVertical;
        }
        if (stemLength) {
          if (stem == null) {
            stem = this.options.stem;
          }
          if (stem.right) {
            position.left -= stemLength;
          } else if (stem.left) {
            position.left += stemLength;
          }
          if (stem.bottom) {
            position.top -= stemLength;
          } else if (stem.top) {
            position.top += stemLength;
          }
        }
      }
      position.left += this.options.offset[0];
      position.top += this.options.offset[1];
      if (tipJoint.right) {
        position.left -= this.dimensions.width;
      } else if (tipJoint.center) {
        position.left -= Math.round(this.dimensions.width / 2);
      }
      if (tipJoint.bottom) {
        position.top -= this.dimensions.height;
      } else if (tipJoint.middle) {
        position.top -= Math.round(this.dimensions.height / 2);
      }
      return position;
    };
  
    Opentip.prototype._ensureViewportContainment = function(e, position) {
      var needsRepositioning, newSticksOut, originals, revertedX, revertedY, scrollOffset, stem, sticksOut, targetJoint, tipJoint, viewportDimensions, viewportPosition;
      stem = this.options.stem;
      originals = {
        position: position,
        stem: stem
      };
      if (!(this.visible && position)) {
        return originals;
      }
      sticksOut = this._sticksOut(position);
      if (!(sticksOut[0] || sticksOut[1])) {
        return originals;
      }
      tipJoint = new Opentip.Joint(this.options.tipJoint);
      if (this.options.targetJoint) {
        targetJoint = new Opentip.Joint(this.options.targetJoint);
      }
      scrollOffset = this.adapter.scrollOffset();
      viewportDimensions = this.adapter.viewportDimensions();
      viewportPosition = [position.left - scrollOffset[0], position.top - scrollOffset[1]];
      needsRepositioning = false;
      if (viewportDimensions.width >= this.dimensions.width) {
        if (sticksOut[0]) {
          needsRepositioning = true;
          switch (sticksOut[0]) {
            case this.STICKS_OUT_LEFT:
              tipJoint.setHorizontal("left");
              if (this.options.targetJoint) {
                targetJoint.setHorizontal("right");
              }
              break;
            case this.STICKS_OUT_RIGHT:
              tipJoint.setHorizontal("right");
              if (this.options.targetJoint) {
                targetJoint.setHorizontal("left");
              }
          }
        }
      }
      if (viewportDimensions.height >= this.dimensions.height) {
        if (sticksOut[1]) {
          needsRepositioning = true;
          switch (sticksOut[1]) {
            case this.STICKS_OUT_TOP:
              tipJoint.setVertical("top");
              if (this.options.targetJoint) {
                targetJoint.setVertical("bottom");
              }
              break;
            case this.STICKS_OUT_BOTTOM:
              tipJoint.setVertical("bottom");
              if (this.options.targetJoint) {
                targetJoint.setVertical("top");
              }
          }
        }
      }
      if (!needsRepositioning) {
        return originals;
      }
      if (this.options.stem) {
        stem = tipJoint;
      }
      position = this.getPosition(e, tipJoint, targetJoint, stem);
      newSticksOut = this._sticksOut(position);
      revertedX = false;
      revertedY = false;
      if (newSticksOut[0] && (newSticksOut[0] !== sticksOut[0])) {
        revertedX = true;
        tipJoint.setHorizontal(this.options.tipJoint.horizontal);
        if (this.options.targetJoint) {
          targetJoint.setHorizontal(this.options.targetJoint.horizontal);
        }
      }
      if (newSticksOut[1] && (newSticksOut[1] !== sticksOut[1])) {
        revertedY = true;
        tipJoint.setVertical(this.options.tipJoint.vertical);
        if (this.options.targetJoint) {
          targetJoint.setVertical(this.options.targetJoint.vertical);
        }
      }
      if (revertedX && revertedY) {
        return originals;
      }
      if (revertedX || revertedY) {
        if (this.options.stem) {
          stem = tipJoint;
        }
        position = this.getPosition(e, tipJoint, targetJoint, stem);
      }
      return {
        position: position,
        stem: stem
      };
    };
  
    Opentip.prototype._sticksOut = function(position) {
      var positionOffset, scrollOffset, sticksOut, viewportDimensions;
      scrollOffset = this.adapter.scrollOffset();
      viewportDimensions = this.adapter.viewportDimensions();
      positionOffset = [position.left - scrollOffset[0], position.top - scrollOffset[1]];
      sticksOut = [false, false];
      if (positionOffset[0] < 0) {
        sticksOut[0] = this.STICKS_OUT_LEFT;
      } else if (positionOffset[0] + this.dimensions.width > viewportDimensions.width) {
        sticksOut[0] = this.STICKS_OUT_RIGHT;
      }
      if (positionOffset[1] < 0) {
        sticksOut[1] = this.STICKS_OUT_TOP;
      } else if (positionOffset[1] + this.dimensions.height > viewportDimensions.height) {
        sticksOut[1] = this.STICKS_OUT_BOTTOM;
      }
      return sticksOut;
    };
  
    Opentip.prototype._draw = function() {
      var backgroundCanvas, bulge, canvasDimensions, canvasPosition, closeButton, closeButtonInner, closeButtonOuter, ctx, drawCorner, drawLine, hb, stemBase, stemLength, _ref, _ref1,
        _this = this;
      if (!(this.backgroundCanvas && this.redraw)) {
        return;
      }
      this.debug("Drawing background.");
      this.redraw = false;
      closeButtonInner = [0, 0];
      closeButtonOuter = [0, 0];
      if (__indexOf.call(this.options.hideTriggers, "closeButton") >= 0) {
        closeButton = new Opentip.Joint(((_ref = this.currentStem) != null ? _ref.toString() : void 0) === "top right" ? "top left" : "top right");
        closeButtonInner = [this.options.closeButtonRadius + this.options.closeButtonOffset[0], this.options.closeButtonRadius + this.options.closeButtonOffset[1]];
        closeButtonOuter = [this.options.closeButtonRadius - this.options.closeButtonOffset[0], this.options.closeButtonRadius - this.options.closeButtonOffset[1]];
      }
      canvasDimensions = this.adapter.clone(this.dimensions);
      canvasPosition = [0, 0];
      if (this.options.borderWidth) {
        canvasDimensions.width += this.options.borderWidth * 2;
        canvasDimensions.height += this.options.borderWidth * 2;
        canvasPosition[0] -= this.options.borderWidth;
        canvasPosition[1] -= this.options.borderWidth;
      }
      if (this.options.shadow) {
        canvasDimensions.width += this.options.shadowBlur * 2;
        canvasDimensions.width += Math.max(0, this.options.shadowOffset[0] - this.options.shadowBlur * 2);
        canvasDimensions.height += this.options.shadowBlur * 2;
        canvasDimensions.height += Math.max(0, this.options.shadowOffset[1] - this.options.shadowBlur * 2);
        canvasPosition[0] -= Math.max(0, this.options.shadowBlur - this.options.shadowOffset[0]);
        canvasPosition[1] -= Math.max(0, this.options.shadowBlur - this.options.shadowOffset[1]);
      }
      bulge = {
        left: 0,
        right: 0,
        top: 0,
        bottom: 0
      };
      if (this.currentStem) {
        if (this.currentStem.left) {
          bulge.left = this.options.stemLength;
        } else if (this.currentStem.right) {
          bulge.right = this.options.stemLength;
        }
        if (this.currentStem.top) {
          bulge.top = this.options.stemLength;
        } else if (this.currentStem.bottom) {
          bulge.bottom = this.options.stemLength;
        }
      }
      if (closeButton) {
        if (closeButton.left) {
          bulge.left = Math.max(bulge.left, closeButtonOuter[0]);
        } else if (closeButton.right) {
          bulge.right = Math.max(bulge.right, closeButtonOuter[0]);
        }
        if (closeButton.top) {
          bulge.top = Math.max(bulge.top, closeButtonOuter[1]);
        } else if (closeButton.bottom) {
          bulge.bottom = Math.max(bulge.bottom, closeButtonOuter[1]);
        }
      }
      canvasDimensions.width += bulge.left + bulge.right;
      canvasDimensions.height += bulge.top + bulge.bottom;
      canvasPosition[0] -= bulge.left;
      canvasPosition[1] -= bulge.top;
      if (this.currentStem && this.options.borderWidth) {
        _ref1 = this._getPathStemMeasures(this.options.stemBase, this.options.stemLength, this.options.borderWidth), stemLength = _ref1.stemLength, stemBase = _ref1.stemBase;
      }
      backgroundCanvas = this.adapter.unwrap(this.backgroundCanvas);
      backgroundCanvas.width = canvasDimensions.width;
      backgroundCanvas.height = canvasDimensions.height;
      this.adapter.css(this.backgroundCanvas, {
        width: "" + backgroundCanvas.width + "px",
        height: "" + backgroundCanvas.height + "px",
        left: "" + canvasPosition[0] + "px",
        top: "" + canvasPosition[1] + "px"
      });
      ctx = backgroundCanvas.getContext("2d");
      ctx.clearRect(0, 0, backgroundCanvas.width, backgroundCanvas.height);
      ctx.beginPath();
      ctx.fillStyle = this._getColor(ctx, this.dimensions, this.options.background, this.options.backgroundGradientHorizontal);
      ctx.lineJoin = "miter";
      ctx.miterLimit = 500;
      hb = this.options.borderWidth / 2;
      if (this.options.borderWidth) {
        ctx.strokeStyle = this.options.borderColor;
        ctx.lineWidth = this.options.borderWidth;
      } else {
        stemLength = this.options.stemLength;
        stemBase = this.options.stemBase;
      }
      if (stemBase == null) {
        stemBase = 0;
      }
      drawLine = function(length, stem, first) {
        if (first) {
          ctx.moveTo(Math.max(stemBase, _this.options.borderRadius, closeButtonInner[0]) + 1 - hb, -hb);
        }
        if (stem) {
          ctx.lineTo(length / 2 - stemBase / 2, -hb);
          ctx.lineTo(length / 2, -stemLength - hb);
          return ctx.lineTo(length / 2 + stemBase / 2, -hb);
        }
      };
      drawCorner = function(stem, closeButton, i) {
        var angle1, angle2, innerWidth, offset;
        if (stem) {
          ctx.lineTo(-stemBase + hb, 0 - hb);
          ctx.lineTo(stemLength + hb, -stemLength - hb);
          return ctx.lineTo(hb, stemBase - hb);
        } else if (closeButton) {
          offset = _this.options.closeButtonOffset;
          innerWidth = closeButtonInner[0];
          if (i % 2 !== 0) {
            offset = [offset[1], offset[0]];
            innerWidth = closeButtonInner[1];
          }
          angle1 = Math.acos(offset[1] / _this.options.closeButtonRadius);
          angle2 = Math.acos(offset[0] / _this.options.closeButtonRadius);
          ctx.lineTo(-innerWidth + hb, -hb);
          return ctx.arc(hb - offset[0], -hb + offset[1], _this.options.closeButtonRadius, -(Math.PI / 2 + angle1), angle2, false);
        } else {
          ctx.lineTo(-_this.options.borderRadius + hb, -hb);
          return ctx.quadraticCurveTo(hb, -hb, hb, _this.options.borderRadius - hb);
        }
      };
      ctx.translate(-canvasPosition[0], -canvasPosition[1]);
      ctx.save();
      (function() {
        var cornerStem, i, lineLength, lineStem, positionIdx, positionX, positionY, rotation, _i, _ref2, _results;
        _results = [];
        for (i = _i = 0, _ref2 = Opentip.positions.length / 2; 0 <= _ref2 ? _i < _ref2 : _i > _ref2; i = 0 <= _ref2 ? ++_i : --_i) {
          positionIdx = i * 2;
          positionX = i === 0 || i === 3 ? 0 : _this.dimensions.width;
          positionY = i < 2 ? 0 : _this.dimensions.height;
          rotation = (Math.PI / 2) * i;
          lineLength = i % 2 === 0 ? _this.dimensions.width : _this.dimensions.height;
          lineStem = new Opentip.Joint(Opentip.positions[positionIdx]);
          cornerStem = new Opentip.Joint(Opentip.positions[positionIdx + 1]);
          ctx.save();
          ctx.translate(positionX, positionY);
          ctx.rotate(rotation);
          drawLine(lineLength, lineStem.eql(_this.currentStem), i === 0);
          ctx.translate(lineLength, 0);
          drawCorner(cornerStem.eql(_this.currentStem), cornerStem.eql(closeButton), i);
          _results.push(ctx.restore());
        }
        return _results;
      })();
      ctx.closePath();
      ctx.save();
      if (this.options.shadow) {
        ctx.shadowColor = this.options.shadowColor;
        ctx.shadowBlur = this.options.shadowBlur;
        ctx.shadowOffsetX = this.options.shadowOffset[0];
        ctx.shadowOffsetY = this.options.shadowOffset[1];
      }
      ctx.fill();
      ctx.restore();
      if (this.options.borderWidth) {
        ctx.stroke();
      }
      ctx.restore();
      if (closeButton) {
        return (function() {
          var crossCenter, crossHeight, crossWidth, hcs, linkCenter;
          crossWidth = crossHeight = _this.options.closeButtonRadius * 2;
          if (closeButton.toString() === "top right") {
            linkCenter = [_this.dimensions.width - _this.options.closeButtonOffset[0], _this.options.closeButtonOffset[1]];
            crossCenter = [linkCenter[0] + hb, linkCenter[1] - hb];
          } else {
            linkCenter = [_this.options.closeButtonOffset[0], _this.options.closeButtonOffset[1]];
            crossCenter = [linkCenter[0] - hb, linkCenter[1] - hb];
          }
          ctx.translate(crossCenter[0], crossCenter[1]);
          hcs = _this.options.closeButtonCrossSize / 2;
          ctx.save();
          ctx.beginPath();
          ctx.strokeStyle = _this.options.closeButtonCrossColor;
          ctx.lineWidth = _this.options.closeButtonCrossLineWidth;
          ctx.lineCap = "round";
          ctx.moveTo(-hcs, -hcs);
          ctx.lineTo(hcs, hcs);
          ctx.stroke();
          ctx.beginPath();
          ctx.moveTo(hcs, -hcs);
          ctx.lineTo(-hcs, hcs);
          ctx.stroke();
          ctx.restore();
          return _this.adapter.css(_this.closeButtonElement, {
            left: "" + (linkCenter[0] - hcs - _this.options.closeButtonLinkOverscan) + "px",
            top: "" + (linkCenter[1] - hcs - _this.options.closeButtonLinkOverscan) + "px",
            width: "" + (_this.options.closeButtonCrossSize + _this.options.closeButtonLinkOverscan * 2) + "px",
            height: "" + (_this.options.closeButtonCrossSize + _this.options.closeButtonLinkOverscan * 2) + "px"
          });
        })();
      }
    };
  
    Opentip.prototype._getPathStemMeasures = function(outerStemBase, outerStemLength, borderWidth) {
      var angle, distanceBetweenTips, halfAngle, hb, rhombusSide, stemBase, stemLength;
      hb = borderWidth / 2;
      halfAngle = Math.atan((outerStemBase / 2) / outerStemLength);
      angle = halfAngle * 2;
      rhombusSide = hb / Math.sin(angle);
      distanceBetweenTips = 2 * rhombusSide * Math.cos(halfAngle);
      stemLength = hb + outerStemLength - distanceBetweenTips;
      if (stemLength < 0) {
        throw new Error("Sorry but your stemLength / stemBase ratio is strange.");
      }
      stemBase = (Math.tan(halfAngle) * stemLength) * 2;
      return {
        stemLength: stemLength,
        stemBase: stemBase
      };
    };
  
    Opentip.prototype._getColor = function(ctx, dimensions, color, horizontal) {
      var colorStop, gradient, i, _i, _len;
      if (horizontal == null) {
        horizontal = false;
      }
      if (typeof color === "string") {
        return color;
      }
      if (horizontal) {
        gradient = ctx.createLinearGradient(0, 0, dimensions.width, 0);
      } else {
        gradient = ctx.createLinearGradient(0, 0, 0, dimensions.height);
      }
      for (i = _i = 0, _len = color.length; _i < _len; i = ++_i) {
        colorStop = color[i];
        gradient.addColorStop(colorStop[0], colorStop[1]);
      }
      return gradient;
    };
  
    Opentip.prototype._searchAndActivateCloseButtons = function() {
      var element, _i, _len, _ref;
      _ref = this.adapter.findAll(this.container, "." + this["class"].close);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        element = _ref[_i];
        this.hideTriggers.push({
          element: this.adapter.wrap(element),
          event: "click"
        });
      }
      if (this.currentObservers.showing) {
        this._setupObservers("-showing", "showing");
      }
      if (this.currentObservers.visible) {
        return this._setupObservers("-visible", "visible");
      }
    };
  
    Opentip.prototype._activateFirstInput = function() {
      var input;
      input = this.adapter.unwrap(this.adapter.find(this.container, "input, textarea"));
      return input != null ? typeof input.focus === "function" ? input.focus() : void 0 : void 0;
    };
  
    Opentip.prototype._followMousePosition = function() {
      if (!this.options.fixed) {
        return this.adapter.observe(document.body, "mousemove", this.bound.reposition);
      }
    };
  
    Opentip.prototype._stopFollowingMousePosition = function() {
      if (!this.options.fixed) {
        return this.adapter.stopObserving(document.body, "mousemove", this.bound.reposition);
      }
    };
  
    Opentip.prototype._clearShowTimeout = function() {
      return clearTimeout(this._showTimeoutId);
    };
  
    Opentip.prototype._clearHideTimeout = function() {
      return clearTimeout(this._hideTimeoutId);
    };
  
    Opentip.prototype._clearTimeouts = function() {
      clearTimeout(this._visibilityStateTimeoutId);
      this._clearShowTimeout();
      return this._clearHideTimeout();
    };
  
    Opentip.prototype._triggerElementExists = function() {
      var el;
      el = this.adapter.unwrap(this.triggerElement);
      while (el.parentNode) {
        if (el.parentNode.tagName === "BODY") {
          return true;
        }
        el = el.parentNode;
      }
      return false;
    };
  
    Opentip.prototype._loadAjax = function() {
      var _this = this;
      if (this.loading) {
        return;
      }
      this.loaded = false;
      this.loading = true;
      this.adapter.addClass(this.container, this["class"].loading);
      this.debug("Loading content from " + this.options.ajax);
      return this.adapter.ajax({
        url: this.options.ajax,
        method: this.options.ajaxMethod,
        onSuccess: function(responseText) {
          _this.debug("Loading successful.");
          _this.adapter.removeClass(_this.container, _this["class"].loading);
          return _this.setContent(responseText);
        },
        onError: function(error) {
          var message;
          message = "There was a problem downloading the content.";
          _this.debug(message, error);
          _this.setContent(message);
          return _this.adapter.addClass(_this.container, _this["class"].ajaxError);
        },
        onComplete: function() {
          _this.adapter.removeClass(_this.container, _this["class"].loading);
          _this.loading = false;
          _this.loaded = true;
          _this._searchAndActivateCloseButtons();
          _this._activateFirstInput();
          return _this.reposition();
        }
      });
    };
  
    Opentip.prototype._ensureTriggerElement = function() {
      if (!this._triggerElementExists()) {
        this.deactivate();
        return this._stopEnsureTriggerElement();
      }
    };
  
    Opentip.prototype._ensureTriggerElementInterval = 1000;
  
    Opentip.prototype._startEnsureTriggerElement = function() {
      var _this = this;
      return this._ensureTriggerElementTimeoutId = setInterval((function() {
        return _this._ensureTriggerElement();
      }), this._ensureTriggerElementInterval);
    };
  
    Opentip.prototype._stopEnsureTriggerElement = function() {
      return clearInterval(this._ensureTriggerElementTimeoutId);
    };
  
    return Opentip;
  
  })();
  
  vendors = ["khtml", "ms", "o", "moz", "webkit"];
  
  Opentip.prototype.setCss3Style = function(element, styles) {
    var prop, value, vendor, vendorProp, _results;
    element = this.adapter.unwrap(element);
    _results = [];
    for (prop in styles) {
      if (!__hasProp.call(styles, prop)) continue;
      value = styles[prop];
      if (element.style[prop] != null) {
        _results.push(element.style[prop] = value);
      } else {
        _results.push((function() {
          var _i, _len, _results1;
          _results1 = [];
          for (_i = 0, _len = vendors.length; _i < _len; _i++) {
            vendor = vendors[_i];
            vendorProp = "" + (this.ucfirst(vendor)) + (this.ucfirst(prop));
            if (element.style[vendorProp] != null) {
              _results1.push(element.style[vendorProp] = value);
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        }).call(this));
      }
    }
    return _results;
  };
  
  Opentip.prototype.defer = function(func) {
    return setTimeout(func, 0);
  };
  
  Opentip.prototype.setTimeout = function(func, seconds) {
    return setTimeout(func, seconds ? seconds * 1000 : 0);
  };
  
  Opentip.prototype.ucfirst = function(string) {
    if (string == null) {
      return "";
    }
    return string.charAt(0).toUpperCase() + string.slice(1);
  };
  
  Opentip.prototype.dasherize = function(string) {
    return string.replace(/([A-Z])/g, function(_, char) {
      return "-" + (char.toLowerCase());
    });
  };
  
  Opentip.Joint = (function() {
  
    function Joint(pointerString) {
      if (pointerString == null) {
        return;
      }
      if (pointerString instanceof Opentip.Joint) {
        pointerString = pointerString.toString();
      }
      this.set(pointerString);
      this;
  
    }
  
    Joint.prototype.set = function(string) {
      string = string.toLowerCase();
      this.setHorizontal(string);
      this.setVertical(string);
      return this;
    };
  
    Joint.prototype.setHorizontal = function(string) {
      var i, valid, _i, _j, _len, _len1, _results;
      valid = ["left", "center", "right"];
      for (_i = 0, _len = valid.length; _i < _len; _i++) {
        i = valid[_i];
        if (~string.indexOf(i)) {
          this.horizontal = i.toLowerCase();
        }
      }
      if (this.horizontal == null) {
        this.horizontal = "center";
      }
      _results = [];
      for (_j = 0, _len1 = valid.length; _j < _len1; _j++) {
        i = valid[_j];
        _results.push(this[i] = this.horizontal === i ? i : void 0);
      }
      return _results;
    };
  
    Joint.prototype.setVertical = function(string) {
      var i, valid, _i, _j, _len, _len1, _results;
      valid = ["top", "middle", "bottom"];
      for (_i = 0, _len = valid.length; _i < _len; _i++) {
        i = valid[_i];
        if (~string.indexOf(i)) {
          this.vertical = i.toLowerCase();
        }
      }
      if (this.vertical == null) {
        this.vertical = "middle";
      }
      _results = [];
      for (_j = 0, _len1 = valid.length; _j < _len1; _j++) {
        i = valid[_j];
        _results.push(this[i] = this.vertical === i ? i : void 0);
      }
      return _results;
    };
  
    Joint.prototype.eql = function(pointer) {
      return (pointer != null) && this.horizontal === pointer.horizontal && this.vertical === pointer.vertical;
    };
  
    Joint.prototype.flip = function() {
      var flippedIndex, positionIdx;
      positionIdx = Opentip.position[this.toString(true)];
      flippedIndex = (positionIdx + 4) % 8;
      this.set(Opentip.positions[flippedIndex]);
      return this;
    };
  
    Joint.prototype.toString = function(camelized) {
      var horizontal, vertical;
      if (camelized == null) {
        camelized = false;
      }
      vertical = this.vertical === "middle" ? "" : this.vertical;
      horizontal = this.horizontal === "center" ? "" : this.horizontal;
      if (vertical && horizontal) {
        if (camelized) {
          horizontal = Opentip.prototype.ucfirst(horizontal);
        } else {
          horizontal = " " + horizontal;
        }
      }
      return "" + vertical + horizontal;
    };
  
    return Joint;
  
  })();
  
  Opentip.prototype._positionsEqual = function(posA, posB) {
    return (posA != null) && (posB != null) && posA.left === posB.left && posA.top === posB.top;
  };
  
  Opentip.prototype._dimensionsEqual = function(dimA, dimB) {
    return (dimA != null) && (dimB != null) && dimA.width === dimB.width && dimA.height === dimB.height;
  };
  
  Opentip.prototype.debug = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    if (Opentip.debug && ((typeof console !== "undefined" && console !== null ? console.debug : void 0) != null)) {
      args.unshift("#" + this.id + " |");
      return console.debug.apply(console, args);
    }
  };
  
  Opentip.findElements = function() {
    var adapter, content, element, optionName, optionValue, options, _i, _len, _ref, _results;
    adapter = Opentip.adapter;
    _ref = adapter.findAll(document.body, "[data-ot]");
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      element = _ref[_i];
      options = {};
      content = adapter.data(element, "ot");
      if (content === "" || content === "true" || content === "yes") {
        content = adapter.attr(element, "title");
        adapter.attr(element, "title", "");
      }
      content = content || "";
      for (optionName in Opentip.styles.standard) {
        if (optionValue = adapter.data(element, "ot" + (Opentip.prototype.ucfirst(optionName)))) {
          if (optionValue === "yes" || optionValue === "true" || optionValue === "on") {
            optionValue = true;
          } else if (optionValue === "no" || optionValue === "false" || optionValue === "off") {
            optionValue = false;
          }
          options[optionName] = optionValue;
        }
      }
      _results.push(new Opentip(element, content, options));
    }
    return _results;
  };
  
  Opentip.version = "2.0.0-dev";
  
  Opentip.debug = false;
  
  Opentip.lastId = 0;
  
  Opentip.lastZIndex = 100;
  
  Opentip.tips = [];
  
  Opentip._abortShowingGroup = function() {};
  
  Opentip._hideGroup = function() {};
  
  Opentip.adapters = {};
  
  Opentip.adapter = null;
  
  firstAdapter = true;
  
  Opentip.addAdapter = function(adapter) {
    Opentip.adapters[adapter.name] = adapter;
    if (firstAdapter) {
      Opentip.adapter = adapter;
      adapter.domReady(Opentip.findElements);
      return firstAdapter = false;
    }
  };
  
  Opentip.positions = ["top", "topRight", "right", "bottomRight", "bottom", "bottomLeft", "left", "topLeft"];
  
  Opentip.position = {};
  
  _ref = Opentip.positions;
  for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
    position = _ref[i];
    Opentip.position[position] = i;
  }
  
  Opentip.styles = {
    standard: {
      title: void 0,
      escapeTitle: true,
      escapeContent: false,
      className: "standard",
      stem: true,
      delay: null,
      hideDelay: 0.1,
      fixed: false,
      showOn: "mouseover",
      hideTrigger: "trigger",
      hideTriggers: [],
      hideOn: null,
      offset: [0, 0],
      containInViewport: true,
      autoOffset: true,
      showEffect: "appear",
      hideEffect: "fade",
      showEffectDuration: 0.3,
      hideEffectDuration: 0.2,
      stemLength: 5,
      stemBase: 8,
      tipJoint: "top left",
      target: null,
      targetJoint: null,
      ajax: false,
      ajaxMethod: "GET",
      ajaxCache: true,
      group: null,
      style: null,
      background: "#fff18f",
      backgroundGradientHorizontal: false,
      closeButtonOffset: [5, 5],
      closeButtonRadius: 7,
      closeButtonCrossSize: 4,
      closeButtonCrossColor: "#d2c35b",
      closeButtonCrossLineWidth: 1.5,
      closeButtonLinkOverscan: 6,
      borderRadius: 5,
      borderWidth: 1,
      borderColor: "#f2e37b",
      shadow: true,
      shadowBlur: 10,
      shadowOffset: [3, 3],
      shadowColor: "rgba(0, 0, 0, 0.1)"
    },
    slick: {
      className: "slick",
      stem: true
    },
    rounded: {
      className: "rounded",
      stem: true
    },
    glass: {
      className: "glass",
      background: [[0, "rgba(252, 252, 252, 0.8)"], [0.5, "rgba(255, 255, 255, 0.8)"], [0.5, "rgba(250, 250, 250, 0.9)"], [1, "rgba(245, 245, 245, 0.9)"]],
      borderColor: "#eee",
      closeButtonCrossColor: "rgba(0, 0, 0, 0.2)",
      borderRadius: 15,
      closeButtonRadius: 10,
      closeButtonOffset: [8, 8]
    },
    dark: {
      className: "dark",
      borderRadius: 13,
      borderColor: "#444",
      closeButtonCrossColor: "rgba(240, 240, 240, 1)",
      shadowColor: "rgba(0, 0, 0, 0.3)",
      shadowOffset: [2, 2],
      background: [[0, "rgba(30, 30, 30, 0.7)"], [0.5, "rgba(30, 30, 30, 0.8)"], [0.5, "rgba(10, 10, 10, 0.8)"], [1, "rgba(10, 10, 10, 0.9)"]]
    },
    alert: {
      className: "alert",
      borderRadius: 1,
      borderColor: "#AE0D11",
      closeButtonCrossColor: "rgba(255, 255, 255, 1)",
      shadowColor: "rgba(0, 0, 0, 0.3)",
      shadowOffset: [2, 2],
      background: [[0, "rgba(203, 15, 19, 0.7)"], [0.5, "rgba(203, 15, 19, 0.8)"], [0.5, "rgba(189, 14, 18, 0.8)"], [1, "rgba(179, 14, 17, 0.9)"]]
    }
  };
  
  Opentip.defaultStyle = "standard";
  
  window.Opentip = Opentip;
  
  
  // Generated by CoffeeScript 1.3.3
  var __slice = [].slice,
    __hasProp = {}.hasOwnProperty;
  
  (function($) {
    var Adapter, bean, reqwest;
    bean = require("bean");
    reqwest = require("reqwest");
    $.ender({
      opentip: function(content, title, options) {
        return new Opentip(this, content, title, options);
      }
    }, true);
    Adapter = (function() {
  
      function Adapter() {}
  
      Adapter.prototype.name = "ender";
  
      Adapter.prototype.domReady = function(callback) {
        return $.domReady(callback);
      };
  
      Adapter.prototype.create = function(html) {
        return $(html);
      };
  
      Adapter.prototype.wrap = function(element) {
        element = $(element);
        if (element.length > 1) {
          throw new Error("Multiple elements provided.");
        }
        return element;
      };
  
      Adapter.prototype.unwrap = function(element) {
        return $(element).get(0);
      };
  
      Adapter.prototype.tagName = function(element) {
        return this.unwrap(element).tagName;
      };
  
      Adapter.prototype.attr = function() {
        var args, element, _ref;
        element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        return (_ref = $(element)).attr.apply(_ref, args);
      };
  
      Adapter.prototype.data = function() {
        var args, element, _ref;
        element = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        return (_ref = $(element)).data.apply(_ref, args);
      };
  
      Adapter.prototype.find = function(element, selector) {
        return $(element).find(selector);
      };
  
      Adapter.prototype.findAll = function() {
        return this.find.apply(this, arguments);
      };
  
      Adapter.prototype.update = function(element, content, escape) {
        element = $(element);
        if (escape) {
          return element.text(content);
        } else {
          return element.html(content);
        }
      };
  
      Adapter.prototype.append = function(element, child) {
        return $(element).append(child);
      };
  
      Adapter.prototype.addClass = function(element, className) {
        return $(element).addClass(className);
      };
  
      Adapter.prototype.removeClass = function(element, className) {
        return $(element).removeClass(className);
      };
  
      Adapter.prototype.css = function(element, properties) {
        return $(element).css(properties);
      };
  
      Adapter.prototype.dimensions = function(element) {
        return $(element).dim();
      };
  
      Adapter.prototype.scrollOffset = function() {
        return [window.pageXOffset || document.documentElement.scrollLeft || document.body.scrollLeft, window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop];
      };
  
      Adapter.prototype.viewportDimensions = function() {
        return {
          width: document.documentElement.clientWidth,
          height: document.documentElement.clientHeight
        };
      };
  
      Adapter.prototype.mousePosition = function(e) {
        var pos;
        pos = {
          x: 0,
          y: 0
        };
        if (e == null) {
          e = window.event;
        }
        if (e == null) {
          return;
        }
        if (e.pageX || e.pageY) {
          pos.x = e.pageX;
          pos.y = e.pageY;
        } else if (e.clientX || e.clientY) {
          pos.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
          pos.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
        }
        return pos;
      };
  
      Adapter.prototype.offset = function(element) {
        var offset;
        offset = $(element).offset();
        return {
          top: offset.top,
          left: offset.left
        };
      };
  
      Adapter.prototype.observe = function(element, eventName, observer) {
        return $(element).on(eventName, observer);
      };
  
      Adapter.prototype.stopObserving = function(element, eventName, observer) {
        return $(element).unbind(eventName, observer);
      };
  
      Adapter.prototype.ajax = function(options) {
        var _ref, _ref1;
        if (options.url == null) {
          throw new Error("No url provided");
        }
        return reqwest({
          url: options.url,
          type: 'html',
          method: (_ref = (_ref1 = options.method) != null ? _ref1.toUpperCase() : void 0) != null ? _ref : "GET",
          error: function(resp) {
            return typeof options.onError === "function" ? options.onError("Server responded with status " + resp.status) : void 0;
          },
          success: function(resp) {
            return typeof options.onSuccess === "function" ? options.onSuccess(resp) : void 0;
          },
          complete: function() {
            return typeof options.onComplete === "function" ? options.onComplete() : void 0;
          }
        });
      };
  
      Adapter.prototype.clone = function(object) {
        var key, newObject, val;
        newObject = {};
        for (key in object) {
          if (!__hasProp.call(object, key)) continue;
          val = object[key];
          newObject[key] = val;
        }
        return newObject;
      };
  
      Adapter.prototype.extend = function() {
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
  
      return Adapter;
  
    })();
    return Opentip.addAdapter(new Adapter);
  })(ender);
  

  provide("opentip", module.exports);

}());