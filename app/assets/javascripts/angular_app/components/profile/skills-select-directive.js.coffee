skillsSelect = ($timeout, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/profile/skills-select.html"
  replace: true
  scope: {
    item: "="
    profile: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      $scope.skillOptions = $scope.profile.skills.map (a) ->
        {value: a, text: a}

      $(elem).selectize
        delimiter: ", "
        persist: true
        valueField: "value"
        labelField: "text"
        items: $scope.item.skills
        options: $scope.skillOptions
        create: (input) ->
          {
            value: input
            text: input
          }

skillsSelect.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "skillsSelect", skillsSelect
