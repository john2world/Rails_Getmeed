# Expects related to be passed in
relatedArticles = (CONSTS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/related-articles.html"
  replace: true
  scope: {
    related: "="
  }

relatedArticles.$inject = [
  "CONSTS"
]

angular.module("meed").directive "relatedArticles", relatedArticles
