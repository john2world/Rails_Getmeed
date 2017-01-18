companyList = ($timeout, CONSTS, CurrentUserFactory) ->

  return {
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/company/company-list.html"
  replace: true
  scope: {
    companies: "="
    currentUser: "="
    companyRecommendations: "="
  }

  link: ($scope, elem, attrs) ->
    $timeout ->
      if CurrentUserFactory.serverSideLoggedIn()
        CurrentUserFactory.getCurrentUser().success (data) ->
          if data.success
            $scope.currentUser = data

  }

companyList.$inject = [
  "$timeout"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "companyList", companyList
