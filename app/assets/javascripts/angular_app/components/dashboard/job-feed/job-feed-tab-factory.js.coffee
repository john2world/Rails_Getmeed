JobFeedTabFactory = () ->
  currentTab: "all"
  isSet: (a) -> a == @currentTab
  setTab: (newValue) ->
    @currentTab = newValue

angular.module("meed").factory "JobFeedTabFactory", JobFeedTabFactory
