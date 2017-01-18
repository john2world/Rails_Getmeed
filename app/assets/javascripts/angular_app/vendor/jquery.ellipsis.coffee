# http://stackoverflow.com/questions/536814/insert-ellipsis-into-html-tag-if-content-too-wide#answer-9071361
(($) ->
  # setup handlers for events for show/hide
  # this is a binary search that operates via a function
  # func should return < 0 if it should search smaller values
  # func should return > 0 if it should search larger values
  # func should return = 0 if the exact value is found
  # Note: this function handles multiple matches and will return the last match
  # this returns -1 if no match is found

  binarySearch = (length, func) ->
    low = 0
    high = length - 1
    best = -1
    mid = undefined
    while low <= high
      mid = ~ ~((low + high) / 2)
      #~~ is a fast way to convert something to an int
      result = func(mid)
      if result < 0
        high = mid - 1
      else if result > 0
        low = mid + 1
      else
        best = mid
        low = mid + 1
    best

  $.each [
    'show'
    'toggleClass'
    'addClass'
    'removeClass'
  ], ->
    #get the old function, e.g. $.fn.show   or $.fn.hide
    oldFn = $.fn[this]

    $.fn[this] = ->
      # get the items that are currently hidden
      hidden = @find(':hidden').add(@filter(':hidden'))
      # run the original function
      result = oldFn.apply(this, arguments)
      # for all of the hidden elements that are now visible
      hidden.filter(':visible').each ->
        # trigger the show msg
        $(this).triggerHandler 'show'
        return
      result

    return
  # create the ellipsis function
  # when addTooltip = true, add a title attribute with the original text

  $.fn.ellipsis = (addTooltip) ->
    @each ->
      el = $(this)
      if el.is(':visible')
        if el.css('overflow') == 'hidden'
          content = el.html()
          multiline = el.hasClass('multiline')

          # KJ Added max-height part here
          tempElement = $(@cloneNode(true)).hide().css('position', 'absolute').css('overflow', 'visible').css("max-height", "none").width(if multiline then el.width() else 'auto').height(if multiline then 'auto' else el.height())

          el.after tempElement

          tooTallFunc = ->
            # console.log tempElement.height()
            # console.log el.height()

            tempElement.height() > el.height()

          tooWideFunc = ->
            tempElement.width() > el.width()

          tooLongFunc = if multiline then tooTallFunc else tooWideFunc
          # if the element is too long...
          if tooLongFunc()
            tooltipText = null
            # if a tooltip was requested...
            if addTooltip
              # trim leading/trailing whitespace
              # and consolidate internal whitespace to a single space
              tooltipText = $.trim(el.text()).replace(/\s\s+/g, ' ')
            originalContent = content

            createContentFunc = (i) ->
              content = originalContent.substr(0, i)
              tempElement.html content + '…'
              return

            searchFunc = (i) ->
              createContentFunc i
              if tooLongFunc()
                return -1
              0

            len = binarySearch(content.length - 1, searchFunc)
            createContentFunc len
            el.html tempElement.html()
            # add the tooltip if appropriate
            if tooltipText != null
              el.attr 'title', tooltipText
          tempElement.remove()
      else
        # if this isn't visible, then hook up the show event
        el.one 'show', ->
          $(this).ellipsis addTooltip
          return
      return

  # ellipsification for items with an ellipsis
  $(document).ready ->
    $('.ellipsis').ellipsis true
    return
  return
) jQuery

