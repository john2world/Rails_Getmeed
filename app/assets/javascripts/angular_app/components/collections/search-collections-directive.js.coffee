searchCollections = ($timeout, CONSTS, UTILS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/search-collections.html"
  replace: true
  scope: {
    collections: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      $input = $(elem).find(".search-collections-input")
      sel = $input.selectize
        persist: false
        maxItems: null
        delimiter: ","
        valueField: '_id'
        labelField: 'title'
        searchField: [
          'title',
          'category'
        ]
        options: $scope.collections
        render:
          item: (item, escape) ->
            '<div>' + (if item.title then '<span class="title">' + escape(item.title) + '</span>' else '') + '</div>'
          option: (item, escape) ->
            label = item.title
#            caption = if item.owned  then " Own collection" else " Public Collection"
            caption = item.category

            '<div>' + '<span class="label">' + escape(label) + '</span>' + (if caption then '<span class="caption">' + escape(caption) + '</span>' else '') + '</div>'
        create: (input) ->
          @off "change"
          UTILS.redirect("/collections/new/?title=#{input}")
          {
            value: input,
            text: input
          }


      sel.on "change", (e) ->
        collectionId = $input.val()
        UTILS.redirect("/submit/post/#{collectionId}")


      # sel.on "item_add", (value, $item) ->


searchCollections.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "searchCollections", searchCollections
