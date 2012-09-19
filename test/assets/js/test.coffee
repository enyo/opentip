#= require_tree tests



window.Test =
  triggerEvent: (element, event) ->
    if document.createEvent?
      # dispatch for firefox + others
      evt = document.createEvent "HTMLEvents"
      evt.initEvent event, true, true # event type,bubbling,cancelable
      element.dispatchEvent evt
    else
      # dispatch for IE
      evt = document.createEventObject()
      element.fireEvent "on#{event}", evt

  clickElement: (element) ->
    @triggerEvent element, "click"
