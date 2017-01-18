WysihtmlFactory = ($http) ->
  initWysihtml = (textareaId, toolbarId) ->
    $textarea = $("##{textareaId}")

    if $textarea.hasClass("has-wysihtml")
      return

    editor = new wysihtml5.Editor(textareaId,
      toolbar: toolbarId
      useLineBreaks: false
      parserRules: wysihtml5ParserRules
    )

    # console.log "inited #{textareaId}"

    $textarea.addClass("has-wysihtml")

    # This is necessary to sync up the values with the angular model
    editor.on "change", () ->
      $textarea.trigger("input");

    editor

  destroyWysihtml = ($textarea) ->
    $("iframe.wysihtml5-sandbox, input[name='_wysihtml5_mode']").remove()
    $("body").removeClass("wysihtml5-supported")
    $textarea.show()
    $textarea.removeClass("has-wysihtml")
    # console.log "destroyed"

  disableWysihtml = (editor) ->
   editor.composer.disable()

  enableWysihtml = (editor) ->
   editor.composer.enable()


  return {
    initWysihtml: initWysihtml
    destroyWysihtml: destroyWysihtml
    disableWysihtml: disableWysihtml
    enableWysihtml: enableWysihtml

  }

WysihtmlFactory.$inject = [
  "$http"
]

angular.module("meed").factory "WysihtmlFactory", WysihtmlFactory
