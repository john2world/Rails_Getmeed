JobFeedUIFactory = () ->

  # Returns the width and height of scrollbars
  getScrollSizes = () ->
    el = document.createElement('div')
    el.style.visibility = 'hidden'
    el.style.overflow = 'scroll'
    document.body.appendChild el
    w = el.offsetWidth - (el.clientWidth)
    h = el.offsetHeight - (el.clientHeight)
    document.body.removeChild el
    new Array(w, h)

  setJobsContainerWidth = () ->
    width = 0
    $('.job-feed-item:visible').each -> width += $(this).outerWidth(true)
    width += 250
    $('#jobs-inner-wrap').css(width: width) #  + 250

  # Currently unused
  setHeightScrollbarHider = () ->
    # Set the height of the scrollbar hider
    scrollSizes = getScrollSizes()
    jobsOuterWrap = $("#jobs-outer-wrap")
    newHeight = jobsOuterWrap.height() - scrollSizes[1]
    $("#jobs-scrollbar-hider").css(height: "#{newHeight}px" )

    # TODO: separate this out to its own function
    # $(".scroll").css(height: "#{newHeight}px" )

  initScrollOnHover = () ->
    scrollAmount = 500
    jobsScrollRight = () ->
      $("#jobs-outer-wrap").stop().animate { scrollLeft: "+=#{scrollAmount}" }, 1000, "linear", jobsScrollRight

    jobsScrollLeft = () ->
      $("#jobs-outer-wrap").stop().animate { scrollLeft: "-=#{scrollAmount}" }, 1000, "linear", jobsScrollLeft

    jobsScrollStop = () -> $("#jobs-outer-wrap").stop()

    $document = $( document )

    $document.on("mouseover", ".scroll.jobs-scroll-right", {}, jobsScrollRight)
    $document.on("mouseout", ".scroll.jobs-scroll-right", {}, jobsScrollStop)
    $document.on("mouseover", ".scroll.jobs-scroll-left", {}, jobsScrollLeft)
    $document.on("mouseout", ".scroll.jobs-scroll-left", {}, jobsScrollStop)


  return {
    setJobsContainerWidth:   setJobsContainerWidth
    setHeightScrollbarHider: setHeightScrollbarHider
    initScrollOnHover:       initScrollOnHover
  }

angular.module("meed").factory "JobFeedUIFactory", JobFeedUIFactory
