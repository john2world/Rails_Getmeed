ArticleController = (
  $scope,
  $timeout,
  $cookies,
  UTILS,
  $location,
  ArticleFactory,
  CurrentUserFactory,
  ActivityFeedItemFactory,
  CommentFactory,
  RelatedArticleFactory) ->

  $scope.loadArticle = (path) ->
    ArticleFactory.getArticle(path).then (response) ->
      data = response.data

      article = new ActivityFeedItemFactory(data.article)
      if article.comments
        article.comments = article.comments.map( (e) ->
          new CommentFactory(e)
        )

      $scope.article = article
      if $scope.article.caption
        UTILS.setPageTitle("#{$scope.article.caption}")
      else
        UTILS.setPageTitle("#{$scope.article.title}")

      if $scope.currentUser.handle == $scope.article.poster_id
        if !$cookies.get("share_own_article")
          $cookies.put("share_own_article", 'true')
          $timeout ->
            UTILS.openModal("#feed-item-social-share-#{$scope.article._id }")
          , 2000

      $scope.related = data.related_content
      if $scope.related
        $scope.related = $scope.related.map( (e) ->
          new RelatedArticleFactory(e)
        )


  $scope.article = ArticleFactory.getCachedArticle($location.path())
  CurrentUserFactory.getCurrentUser().success (data) ->
    if data.success
      $scope.currentUser = data



ArticleController.$inject = [
  "$scope"
  "$timeout"
  "$cookies"
  "UTILS"
  "$location"
  "ArticleFactory"
  "CurrentUserFactory"
  "ActivityFeedItemFactory"
  "CommentFactory"
  "RelatedArticleFactory"
]

angular.module("meed").controller "ArticleController", ArticleController
