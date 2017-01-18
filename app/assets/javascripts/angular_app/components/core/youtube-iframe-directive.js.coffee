
youtubeIframe = ($timeout, CONSTS, UTILS) ->

  ctrl = ($scope) ->
    youtubeId = UTILS.youtubeId($scope.youtubeUrl)
    $scope.youtubeEmbedUrl = "https://www.youtube.com/embed/#{youtubeId}?autoplay=0&controls=1&showinfo=0&rel=0"
    $scope.height ||= 360
    $scope.width ||= 640

  ctrl.$inject = [
    "$scope"
  ]

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/core/youtube-iframe.html"
    replace: false
    scope:{
      height: "@"
      width: "@"
      youtubeUrl: "="
    }
    controller: ctrl

    link: ($scope, elem, attrs) ->
      $timeout ->
        # Do stuff
  }

youtubeIframe.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module( "meed" ).directive "youtubeIframe", youtubeIframe
