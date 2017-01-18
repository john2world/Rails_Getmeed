tagsSelect = ($timeout, CONSTS, UTILS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/tags/tags-select.html"
  replace: true
  scope: {
    tags: "="
    tagId: '='
    selectedTags: "="
  }
  link: ($scope, elem, attrs) ->
    $scope.selectedTags = $scope.selectedTags || []
    unless $scope.tagId
      $scope.tagId = $scope.selectedTags.map (tag) -> tag._id

    $timeout ->
      $input = $(elem).find(".search-tags-input")
      sel = $input.selectize
        persist: false
        maxItems: 3
        delimiter: ","
        createText: "Add new tag "
        valueField: '_id'
        labelField: 'title'
        plugins: ['remove_button']
        dropdownParent: 'body'
        searchField: [
          'title'
        ]
        create: true
        options: $scope.tags
        render:
          item: (item, escape) ->
            '<div>' + (if item.title then '<span class="title">' + escape(item.title) + '</span>' else '') + '</div>'
          option: (item, escape) ->
            label = item.title
            '<div>' + '<i class="' + "fa fa-#{item.icon}" + '"></i> ' + '<span class="label">' + escape(label) + '</span> ' + '</div>'

      sel.on "change", (e) ->
        $scope.$parent.publishFormData.tag_ids = $input.val().split(",") if $scope.$parent.publishFormData
        $scope.tagId = $input.val().split(",")
        $scope.selectedTags = $input.val().split(",").map (tagName) ->
          # find tag by id or create one with id only
          tags = $scope.tags.filter (tag) -> tagName == tag._id
          tags[0] || {"_id": tagName, "title": tagName, "icon": "tag"}
        $scope.selectedTagIds = $input.val().split(",")

# sel.on "item_add", (value, $item) ->


tagsSelect.$inject = [
  "$timeout"
  "CONSTS"
  "UTILS"
]

angular.module("meed").directive "tagsSelect", tagsSelect
