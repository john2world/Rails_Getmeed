angular.module('meed').directive 'googleplace', ->
  require: 'ngModel'
  link: (scope, element, attrs, model) ->
    options =
      types: []
      componentRestrictions: {}

    scope.gPlace = new google.maps.places.Autocomplete(element[0], options)

    google.maps.event.addListener scope.gPlace, 'place_changed', ->
      scope.$apply ->
        model.$setViewValue element.val()

    google.maps.event.addDomListener element[0], 'keydown', (e) ->
      e.preventDefault() if (e.keyCode == 13)
