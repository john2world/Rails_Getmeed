influencersProfileHeader = (CONSTS, $timeout) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/influencers-profile-header.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $scope.namePattern = CONSTS.name_pattern
    $scope.generalEmailPattern = CONSTS.general_email_pattern
    $scope.phoneNumberPattern = CONSTS.phone_number_pattern
    $scope.gpaPattern = CONSTS.gpa_pattern
    $timeout ->
      elem.find(".open-profile-edit-header-modal").click ->
        $("#profile-edit-header-modal").show()


influencersProfileHeader.$inject = [
  "CONSTS"
  "$timeout"
]

angular.module("meed").directive "influencersProfileHeader", influencersProfileHeader

# http://beta.getmeed.com/profiles/header/save





