JobFollowupFactory = (MeedApiFactory) ->
  submitFollowUp = (data, success = false) ->
    url     = "/job/contact_recruiter"
    MeedApiFactory.post({url: url, data: data, success: success})

  return {
    submitFollowUp: submitFollowUp
  }

JobFollowupFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "JobFollowupFactory", JobFollowupFactory
