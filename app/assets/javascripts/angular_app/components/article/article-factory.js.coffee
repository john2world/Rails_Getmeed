ArticleFactory = (MeedApiFactory) ->
  articleCache = { }

  addArticleToCache = (path, data) ->
    articleCache[path] = data

  getCachedArticle = (path) ->
    articleCache[path]

  getArticle = (path) ->
    MeedApiFactory.get({url: path, cached: true})

  return {
    addArticleToCache: addArticleToCache
    getCachedArticle: getCachedArticle
    getArticle: getArticle
  }

ArticleFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "ArticleFactory", ArticleFactory
