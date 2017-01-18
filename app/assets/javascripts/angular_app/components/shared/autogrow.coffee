# Emit onSubmitTextarea on textarea submit
angular.module("meed").directive 'autogrow', ['$timeout', ($timeout) ->
  restrict: 'A'
  link: (scope, element, attr) ->
    $timeout ->
      height = "#{25 + element[0].scrollHeight}px"
      $(element[0]).attr('style', "height: #{height}")

    element.on "blur keyup change paste", ->
      if this.value != ''
        this.style.height = "1px"
        this.style.height = (25 + this.scrollHeight)+"px"
]
