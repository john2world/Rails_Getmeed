MeedpostRequestFactory = (MeedApiFactory) ->
  save = () ->
    data = {
      survey: {
        meediorite_interest: "yes"
      }
    }
    MeedApiFactory.post({url: "/surveys/take_survey", data: data})

  return {
    save: save
  }

MeedpostRequestFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "MeedpostRequestFactory", MeedpostRequestFactory
