ProfileEditTabFactory = () ->
  tabs: {
    "header": false
    "objective": false
    "bio": false

  }

  isSet: (a) -> @tabs[a]

  setTab: (tab, newValue = true) ->
    @tabs[tab] = newValue

angular.module("meed").factory "ProfileEditTabFactory", ProfileEditTabFactory
