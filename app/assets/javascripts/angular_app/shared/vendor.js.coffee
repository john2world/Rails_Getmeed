# Simple functions for loading vendor libraries

angular.module("meed").constant "VENDOR", {


  hasFilePickerLoaded: () ->
    $els = $('input[type="filepicker"]')
    if $els.length != 0
      return true
    else
      return false

  # Unminfied and coffeescripted version of
  # https://www.filepicker.com/documentation/
  # Putting it here so we have more control over when it is loaded
  loadFilepicker: (cb = false) ->
    ((a) ->
      if window.filepicker
        # KJ ADDED callback here
        cb(false) if cb
        return
      b = a.createElement("script")
      b.type = "text/javascript"
      b.async = true
      b.src = (if "https:" == a.location.protocol then "https:" else "http:") + "//api.filepicker.io/v2/filepicker.js"
      c = a.getElementsByTagName("script")[0]
      c.parentNode.insertBefore b, c
      d = {}
      d._queue = []
      e = "pick,pickMultiple,pickAndStore,read,write,writeUrl,export,convert,store,storeUrl,remove,stat,setKey,constructWidget,makeDropPane".split(",")

      f = (a, b) ->
        ->
          b.push [
            a
            arguments
          ]
      g = 0
      while g < e.length
        d[e[g]] = f(e[g], d._queue)
        g++
      window.filepicker = d
      cb(true) if cb
    ) document

  # Used to manually create filepicker widgets
  # For example: when the inputs are created after the filepicker
  # js has been loaded
  createFilepickerWidgets: (firstTime = false) ->
    return if firstTime
    $els = $('input[type="filepicker"]')
    for el in $els
      do (el) ->
        unless $(el).siblings("button.filepicker-button").length
          filepicker.constructWidget(el)

  loadFacebook: (cb = false) ->


  loadTwitter: (cb = false) ->
    window.twttr = ((d, s, id) ->
      fjs = d.getElementsByTagName(s)[0]
      t = window.twttr or {}
      return t if d.getElementById(id)
      js = d.createElement(s)
      js.id = id
      js.src = 'https://platform.twitter.com/widgets.js'
      fjs.parentNode.insertBefore js, fjs
      t._e = []
      t.ready = (f) ->
        t._e.push f
      t
    )(document, 'script', 'twitter-wjs')
    if cb
      cb()



}
