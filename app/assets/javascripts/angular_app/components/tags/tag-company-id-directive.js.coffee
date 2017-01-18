tagCompanyId = ($timeout, CONSTS, UTILS, CompanyFactory, MeedApiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/tags/tag-company-id.html"
  replace: true
  scope:
    onlyOne: "="
    model: "="
    placeholderOverride: '@'
    initialOption: '='
    required: '@'
  link: ($scope, elem, attrs) ->
    $scope.required ||= 'false'
    $scope.placeholderOverride ||= 'Current Company (*)'
    $timeout ->
      $input = $(elem).find(".search-company-input")
      options = if $scope.initialOption
        [$scope.initialOption]
      else
        []

      maxItems = if $scope.onlyOne
        $input.attr('required', 'required')
        1
      else
        3

      sel = $input.selectize
        persist: true
        maxItems: maxItems
        delimiter: ","
        create: true
        valueField: 'id'
        labelField: 'name'
        searchField: ['name']
        options: options
        render:
          item: (item, escape) ->
            '<div>' + (if item.name then '<span class="title">' + escape(item.name) + '</span>' else '') + '</div>'
          option: (item, escape) ->
            label = item.name
            #            caption = if item.owned  then " Own company" else " Public Collection"
            '<div>' + '<span class="label">' + escape(label) + '</span>' + '</div>'
        load: (query, callback) ->
          if (!query.length)
            return callback()
          MeedApiFactory.get(
            url: "/companies?q=#{escape(query)}",
            error: callback,
            success: (companies) ->
              callback(companies)
          )

      sel.on "change", (e) ->
        if $scope.onlyOne
          $scope.model = $input.val()
        else
          $scope.model = $input.val().split(",")

tagCompanyId.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
  "CompanyFactory"
  "MeedApiFactory"
]

angular.module("meed").directive "tagCompanyId", tagCompanyId
