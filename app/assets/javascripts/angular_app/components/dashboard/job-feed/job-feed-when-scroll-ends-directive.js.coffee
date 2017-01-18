jobFeedWhenScrollEnds = () ->
  restrict: 'A'
  link: (scope, element, attrs) ->
    visibleHeight = element.height()
    threshold = 100
    element.scroll ->
      if $("#end-of-job-feed").length > 0
        offset = $("#end-of-job-feed").offset()
        if offset.left <= $(document).width()
          scope.$apply attrs.jobFeedWhenScrollEnds
      else
        element.unbind "scroll"

angular.module("meed").directive "jobFeedWhenScrollEnds", jobFeedWhenScrollEnds

