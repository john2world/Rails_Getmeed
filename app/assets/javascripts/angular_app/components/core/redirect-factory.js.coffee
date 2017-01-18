# Factory for all business logic related to redirections on the page based on actions and state
RedirectFactory = (UTILS, $cookies) ->

  isInfluencerAuthFlow = () ->
    cookieFlag = $cookies.get("influencer_auth_flow")
    return (cookieFlag != null and cookieFlag != '' and cookieFlag != undefined)

  setRedirectUrl = (url) ->
    if url != null && url != '' && url != undefined
      $cookies.put("redirect_url", url)

  setInfluencerAuthFlow = () ->
    $cookies.put("influencer_auth_flow", 'true')

  followRedirectUrl = () ->
    # clear the redirect url
    url = getRedirectUrl()
    if url != null && url != '' && url != undefined
      clearRedirect()
      UTILS.redirect(url)
    else
      clearRedirect()
      UTILS.redirect('/')

  getRedirectUrl = () ->
    url = $cookies.get("redirect_url")
    if url == null || url == '' || url == undefined
      url = '/'
    return url

  hasRedirect = () ->
    url = getRedirectUrl()
    if url == null
      return false
    else
      return true

  clearRedirect = () ->
    $cookies.remove("redirect_url")

  return {
    isInfluencerAuthFlow: isInfluencerAuthFlow
    hasRedirect: hasRedirect
    getRedirectUrl: getRedirectUrl
    followRedirectUrl: followRedirectUrl
    setRedirectUrl: setRedirectUrl
    clearRedirect: clearRedirect
    setInfluencerAuthFlow: setInfluencerAuthFlow
  }

RedirectFactory.$inject = [
  "UTILS"
  "$cookies"
]

angular.module('meed').factory 'RedirectFactory', RedirectFactory