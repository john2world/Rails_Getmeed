CollectionCategoriesFactory = (MeedApiFactory) ->
  all = () ->
    url = "/categories/all"
    MeedApiFactory.get(url)

  getCategory = (slug) ->
    url = "/categories/#{slug}"
    MeedApiFactory.get(url)

  return {
    all: all
    getCategory: getCategory
  }

CollectionCategoriesFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "CollectionCategoriesFactory", CollectionCategoriesFactory
