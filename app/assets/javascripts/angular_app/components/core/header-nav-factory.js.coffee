HeaderNavFactory = (
  UTILS,
  $cookies) ->
  _hidden  = false
  _bg_hidden = false
  _is_influencer = false

  return {
    isHidden: () ->
      _hidden
    setHidden: (newValue) ->
      _hidden = newValue
    isBgHidden: () ->
      _bg_hidden
    setBgHidden: (newValue) ->
      _bg_hidden = newValue
    isInfluencer: () ->
      _is_influencer
    setInfluencer: (newValue) ->
      _is_influencer = newValue
    openSignupModal: () ->
      if _is_influencer
        $cookies.put('signup-type', 'influencer')
        UTILS.openModal("#influencer-signup-modal", {fixed: false})
      else
        $cookies.put('signup-type', 'regular')
        UTILS.openModal("#signup-modal", {fixed: false})
  }

HeaderNavFactory.$inject = [
  "UTILS",
  "$cookies"
]

angular.module("meed").factory "HeaderNavFactory", HeaderNavFactory

