SettingsFactory = (MeedApiFactory) ->
  getSettings = () ->
    url = "/settings"
    MeedApiFactory.get(url)

  saveSettings = (handle, data) ->
    url = "/settings/#{handle}/update"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  deactivateAccount = (data) ->
    url = "/settings/deactivate_survey"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  return {
    getSettings: getSettings
    saveSettings: saveSettings
    deactivateAccount: deactivateAccount
  }

SettingsFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "SettingsFactory", SettingsFactory
