ActivityFeedController = (
  $scope,
  $routeParams,
  $cacheFactory,
  CurrentUserFactory,
  ActivityFeedFactory,
  ActivityFeedItemFactory,
  ActivityFeedTabFactory) ->

  if !$routeParams.companySlug # Not on a company page

    $scope.activityFeedTab = ActivityFeedTabFactory

    if CurrentUserFactory.serverSideLoggedIn()
      CurrentUserFactory.getCurrentUser().success (data) ->
        if data.success
          $scope.currentUser = data


  # Returns true if we should show a given feed item
  $scope.showItem = (item) ->
    profileUpdateTypes =  [
      "coursework"
      "education"
      "internship"
      "publication"
      "photo"
      "userwork"
    ]
    $scope.activityFeedTab.isSet("all") ||
    ($scope.activityFeedTab.isSet("company-updates") && item.poster_type == "company") ||
    ($scope.activityFeedTab.isSet("course-review") && item.type == "course_review") ||
    ($scope.activityFeedTab.isSet("profile-updates") &&
      item.poster_type == "user" &&
      profileUpdateTypes.indexOf(item.type) != -1)


ActivityFeedController.$inject = [
  "$scope"
  "$routeParams"
  "$cacheFactory"
  "CurrentUserFactory"
  "ActivityFeedFactory"
  "ActivityFeedItemFactory"
  "ActivityFeedTabFactory"
]


angular.module("meed").controller "ActivityFeedController", ActivityFeedController
