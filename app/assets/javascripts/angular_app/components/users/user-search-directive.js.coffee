userSearch = (CONSTS, $timeout, MeedApiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/users/user-search.html"
  scope: {
    leadUsers: "="
  }
  replace: true
  link: ($scope, elem, attrs) ->
    $inputfield = $("#user-search")
    $results = $("#user-search-results")
    $clear = $(".search .clear")
    $close = $("#user-search-results .close")
    searchUrl = "/user/lead/recommendations"
    searchCallback = (data, success) ->
      if data.lead_users
        $scope.leadUsers = data.lead_users

    $timeout ->
    $scope.$on('advanced-searchbox:modelUpdated', (event, model) ->
      $scope.leadUsers = []
      $results.show()
      $clear.show()
      MeedApiFactory.post({url: searchUrl, data: model, success: searchCallback})
    )

    $scope.availableSearchParams = []

userSearch.$inject = [
  "CONSTS"
  "$timeout"
  "MeedApiFactory"
]

angular.module("meed").directive "userSearch", userSearch
