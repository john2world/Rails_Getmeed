tagCollections = ($timeout, CONSTS, UTILS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/collections/tag-collections.html"
  replace: true
  scope: {
    collections: "="
    selectedCollections: "="
    collectionId: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.selectedCollections = $scope.selectedCollections || []
    if $scope.selectedCollections.length > 0
      $scope.collectionId = $scope.selectedCollections[0]._id

    $timeout ->
      $input = $(elem).find(".search-collections-input")

      sel = $input.selectize
        persist: false
        maxItems: 1
        delimiter: ","
        valueField: '_id'
        labelField: 'title'
        dropdownParent: 'body'
        searchField: [
          'title'
        ]
        options: $scope.collections
        render:
          item: (item, escape) ->
            '<div>' + (if item.title then '<span class="title">' + escape(item.title) + '</span>' else '') + '</div>'
          option: (item, escape) ->
            label = item.title + ' ' + '(' + item.follower_count + ' members)'
            '<div>' + (if item.private then '<i class="fa fa-graduation-cap private"/></i> ' else '<i class="fa fa-globe private"/></i> ') + '<span class="label">' + escape(label) + '</span> '+ '</div>'
        create: false


      sel.on "change", (e) ->
        $scope.$parent.publishFormData.collection_ids = $input.val().split(",") if $scope.$parent.publishFormData
        $scope.collectionId = $input.val()
        $scope.selectedCollections = $scope.collections.filter (collection) ->
          $input.val() == collection._id

# sel.on "item_add", (value, $item) ->


tagCollections.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "tagCollections", tagCollections
