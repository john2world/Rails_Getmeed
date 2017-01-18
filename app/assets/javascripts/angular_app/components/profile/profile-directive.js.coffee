profile = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/profile.html"
  replace: true
  link: ($scope, elem, attrs) ->
    # A hack to run this stuff only after the element is FULLY loaded
    # For some reason, using elem.ready didn't work
    # http://ejohn.org/blog/how-javascript-timers-work/
    # $timeout ->


    # $timeout () ->
    #   $("abbr.timeago").timeago()
    # , 200


profile.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "profile", profile
