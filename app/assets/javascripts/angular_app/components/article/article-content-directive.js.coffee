articleContent = ($timeout, $location, CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/article-content.html"
  replace: true
  scope: {
    currentUser: "="
    related: "="
    article: "="
    loadArticle: "="
    allCollections: "="
    tags: "="
  }
  link: ($scope, elem, attrs) ->
    $timeout ->
      $scope.$on "editItem", (event, item) ->
        $scope.isEditing = true

      $scope.$on "editedItem", (event, item) ->
        $scope.isEditing = false
        $scope.article = item

      if !($scope.article &&
           $scope.related &&
           $scope.related.length > 0 &&
           $scope.article.comments &&
           $scope.article.comments.length > 0)
        $scope.loadArticle($location.path())

articleContent.$inject = [
  "$timeout"
  "$location"
  "CONSTS"
]

angular.module("meed").directive "articleContent", articleContent
