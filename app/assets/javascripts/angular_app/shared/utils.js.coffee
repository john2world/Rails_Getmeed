# Simple utility functions that can be app-wide

angular.module("meed").constant "UTILS", {

  ###*
  # Check whether an object is Array or not
  # @type Boolean
  # @param {object} subject is the variable that is tested for Array identity check
  ###
  isArray: do ->
    # Use compiler's own isArray when available
    if Array.isArray
      return Array.isArray
    # Retain references to variables for performance
    # optimization
    objectToStringFn = Object::toString
    arrayToStringResult = objectToStringFn.call([])
    (subject) ->
      objectToStringFn.call(subject) == arrayToStringResult

  unique: (ar) ->
    if ar.length == 0
      return []
    res = {}
    res[ar[key]] = ar[key] for key in [0..ar.length-1]
    value for key, value of res

clone: (obj) ->
    $.extend(true, {}, obj)

  redirect: (url) ->
    window.location.href = url

  alert: (s) ->
    alert(s)

  reload: (forceGet = false) ->
    location.reload(forceGet)

  randString: (numChars = 12, chars) ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz" unless chars?
    ret = ""
    i = _i = 1
    while (if 1 <= numChars then _i <= numChars else _i >= numChars)
      rnum = Math.floor(Math.random() * chars.length)
      ret += chars.substring(rnum, rnum + 1)
      i = (if 1 <= numChars then ++_i else --_i)
    ret

  removeItemFromList: (item, items, field = "_id") ->
    i = 0
    while i < items.length
      if items[i][field] && items[i][field] == item[field]
        items.splice i, 1
        break
      i++

  youtubeId: (url) ->
    regExp = /^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#\&\?]*).*/
    match = url.match(regExp)
    return match[7] if (match && match[7].length == 11)
    false

  setPageTitle: (title, withTag = true) ->
    if withTag
      title += " - Meed"
    document.title = title



  openModal: (selector, options = {}) ->
    $el = $(selector)
    $(".outermost-wrap").foggy()
    $el.on $.modal.BEFORE_CLOSE, (event, modal) ->
      $(".outermost-wrap").foggy(false)
    $el.modal(options)
    true

  closeModal: () ->
    $.modal.close()

  # Returns the width and height of scrollbars in the browser
  getScrollSizes: () ->
    el = document.createElement("div")
    el.style.visibility = "hidden"
    el.style.overflow = "scroll"
    document.body.appendChild el
    w = el.offsetWidth - el.clientWidth
    h = el.offsetHeight - el.clientHeight
    document.body.removeChild el
    new Array(w, h)

  center: ($elm, options = {fixed: true, marginTopOffset: 0}) ->
    pos = "fixed"
    top = "50%"
    elemHeight = $elm.outerHeight()
    elemWidth = $elm.outerWidth()
    marginTop = -1 * elemHeight / 2
    viewportWidth = $(window).width()
    viewportHeight = $(window).height()
    if !options.fixed || elemHeight + options.marginTopOffset > viewportHeight
      pos = "absolute"
      top = "0px"
      marginTop = options.marginTopOffset

    $elm.css
      position: pos
      top: top
      left: "50%"
      marginTop: marginTop
      marginLeft: -(elemWidth / 2)

  getTextImagePlaceholder: (text, height, width, bgcolor="369FB9", textcolor="ffffff") ->
    textsize = 100 - (10*(text.length - 1))
    "https://dummyimage.com/#{width}x#{height}/#{bgcolor}/#{textcolor}&text=#{text}"
}

