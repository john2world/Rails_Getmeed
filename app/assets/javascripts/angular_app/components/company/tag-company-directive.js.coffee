tagCompany = ($timeout, CONSTS, UTILS, CompanyFactory, MeedApiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/company/tag-company.html"
  replace: true
  scope: {
    onlyOne: "="
    model: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      items = 3
      $input = $(elem).find(".search-company-input")
      if $scope.onlyOne
        $input.attr('required', 'required')
        items = 1
      else
        $input.attr('placeholder', 'Past Companies (Required)')


      sel = $input.selectize
        persist: true
        maxItems: items
        delimiter: "|"
        create: true
        valueField: 'name'
        labelField: 'name'
        searchField: [
          'name'
        ]
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
          url = "/companies/search/#{escape(query)}"
          MeedApiFactory.get({
            url: url,
            error: callback,
            success: (res) ->
              callback(res.results)
          })

      sel.on "change", (e) ->
        if $scope.onlyOne
          $scope.model = $input.val()
        else
          $scope.model = $input.val().split("|")

# sel.on "item_add", (value, $item) ->


tagCompany.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
  "CompanyFactory"
  "MeedApiFactory"
]

angular.module("meed").directive "tagCompany", tagCompany
