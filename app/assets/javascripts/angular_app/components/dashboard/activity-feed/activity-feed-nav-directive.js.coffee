activityFeedNav = (CONSTS, $timeout) ->

  linkFn = ($scope, elem, attrs) ->

    $scope.tab.setTab("all")

    $("#activity-feed-nav .tab-select.all").click ->
      $scope.tab.setTab("all")
      $scope.loadAllFeedItems()
      $scope.$apply()

    $("#activity-feed-nav .tab-select.student").click ->
      $scope.tab.setTab("student")
      $scope.loadStudentFeedItems()
      $scope.$apply()

    $("#activity-feed-nav .tab-select.company").click ->
      $scope.tab.setTab("company")
      $scope.loadCompanyFeedItems()
      $scope.$apply()

    $("#activity-feed-nav .tab-select.course-review" ).click ->
      $scope.tab.setTab("course-review" )
      $scope.loadCourseReviewFeedItems()
      $scope.$apply()

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/dashboard/activity-feed/activity-feed-nav.html"
    replace: true
    link: linkFn
    scope: {
      tab: "="
      loadAllFeedItems: "="
      loadStudentFeedItems: "="
      loadCompanyFeedItems: "="
      loadCourseReviewFeedItems: "="

    }
  }

activityFeedNav.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "activityFeedNav", activityFeedNav
