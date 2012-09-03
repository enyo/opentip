#= require_tree tests



window.clickElement = (element) ->
  if document.createEvent?
    # dispatch for firefox + others
    evt = document.createEvent "HTMLEvents"
    evt.initEvent "click", true, true # event type,bubbling,cancelable
    !element.dispatchEvent evt
  else
    # dispatch for IE
    evt = document.createEventObject()
    element.fireEvent "onclick", evt
