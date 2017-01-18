MeedpostFactory = (MeedApiFactory) ->
  scrape = (url) ->
    data = {url: url}
    MeedApiFactory.post({url: "/scrape", data: data})

  uploadImage = (url) ->
    data = {
      feed_items: {
        file_url: url
      }
    }
    MeedApiFactory.post({url: "/scrape", data: data})

  update = (id, formData) ->
    MeedApiFactory.post(
      url: "/post/#{id}/update"
      data: formData
    )

  publish = (formData) ->
    MeedApiFactory.post(
      url: "/post/publish"
      data: formData
    )

  return {
    scrape: scrape
    uploadImage: uploadImage
    publish: publish
    update: update
  }

MeedpostFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "MeedpostFactory", MeedpostFactory
