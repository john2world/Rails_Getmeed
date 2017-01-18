# http://stackoverflow.com/questions/15807471/prevent-multiple-form-submissions-using-angular-js-disable-form-button#answer-19825570

clickOnce =  ($timeout) ->
  linkFn = (scope, element, attrs) ->
    replacementText = attrs.clickOnce || "Please wait..."
    element.bind 'click', ->
      $timeout (->
        if replacementText
          element.html replacementText
        element.attr 'disabled', true
      ), 0
  return {
    restrict: 'A'
    link: linkFn
  }

clickOnce.$inject = [
  "$timeout"
]

angular.module("meed").directive "clickOnce", clickOnce
