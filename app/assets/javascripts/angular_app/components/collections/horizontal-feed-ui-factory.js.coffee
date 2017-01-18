HorizontalFeedUiFactory = (UTILS) ->
  setInnerWrapWidth = (feedItemSelector, innerWrapSelector, extra = 250) ->
    width = 0
    $("#{feedItemSelector}:visible").each -> width += $(this).outerWidth(true)
    $(innerWrapSelector).css(width: width + extra)

  initScrollOnHover = (outerWrapSelector) ->
    scrollAmount = 1000

    $outerWrap = $(outerWrapSelector)

    scrollRight = () ->
      $outerWrap.stop().animate { scrollLeft: "+=#{scrollAmount}" }, 1000, "linear", scrollRight

    scrollLeft = () ->
      $outerWrap.stop().animate { scrollLeft: "-=#{scrollAmount}" }, 1000, "linear", scrollLeft

    scrollStop = () -> $outerWrap.stop()

    $document = $(document)

    $document.on("mouseover", ".scroll.scroll-right", {}, scrollRight)
    $document.on("mouseout", ".scroll.scroll-right", {}, scrollStop)
    $document.on("mouseover", ".scroll.scroll-left", {}, scrollLeft)
    $document.on("mouseout", ".scroll.scroll-left", {}, scrollStop)

  setHeightScrollbarHider = (outerWrapSelector, scrollbarHiderSelector) ->
    # Set the height of the scrollbar hider
    scrollSizes = UTILS.getScrollSizes()
    outerWrap = $(outerWrapSelector)
    newHeight = outerWrap.height() - scrollSizes[1]
    $(scrollbarHiderSelector).css(height: "#{newHeight}px" )

  return {
    setInnerWrapWidth: setInnerWrapWidth
    initScrollOnHover: initScrollOnHover
    setHeightScrollbarHider: setHeightScrollbarHider
  }

HorizontalFeedUiFactory.$inject = [
  "UTILS"
]

angular.module("meed").factory "HorizontalFeedUiFactory", HorizontalFeedUiFactory
