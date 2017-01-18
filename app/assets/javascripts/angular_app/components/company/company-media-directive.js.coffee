companyMedia = ($timeout, HeaderNavFactory, CONSTS) ->

  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      $scope.$on "ngRepeatFinished", (event) ->
        delay = 5000
        if $scope.company.video_urls && $scope.company.video_urls.length > 0
          delay = false

        $(elem.find(".unslider")).unslider({
          speed: 500     #  The speed to animate each slide (in milliseconds)
          delay: delay   #  The delay between slide animations (in milliseconds)
          complete: null #  A function that gets called after every slide animation
          keys: true     #  Enable keyboard (left, right) arrow shortcuts
          dots: true     #  Display dot navigation
          fluid: true    #  Support responsive design. May break non-responsive designs
        })

      # if company media is present turn bg header off
      if ($scope.company.video_urls && $scope.company.video_urls.length > 0) or ($scope.company.photos && $scope.company.photos.length > 0)
        HeaderNavFactory.setBgHidden(true)

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/company/company-media.html"
    replace: false
    scope: {
      company: "="
    }
    link: linkFn
  }

companyMedia.$inject = [
  "$timeout"
  "HeaderNavFactory"
  "CONSTS"
]

angular.module("meed").directive "companyMedia", companyMedia

