SignupFactory = ($http, MeedApiFactory) ->
  getOauthData = (oauthToken) ->
    url = "/auth/callback?oauth_token=#{oauthToken}"
    MeedApiFactory.get(url)

  saveInfluencerExpertise = (data) ->
    url = "/users/influencers/expertise/save"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  createInfluencerAccount = (data) ->
    url = "/users/influencers/account"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  createAccount = (data) ->
    url = "/users/account"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  emailSignup = (data) ->
    url = "/users/verify"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  verifyEmail = (data) ->
    url = "/users/create"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  waitlistVerify = (data) ->
    url = "/waitlist/verify"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  login = (data) ->
    url = "/login/verify"
    args = {url: url, data: data}
    MeedApiFactory.post(args)

  waitlist_status = (email) ->
    url = "/waitlist_status?email=#{email}"
    MeedApiFactory.get(url)

  school_lookup = (email) ->
    args = {data: {email: email}, url: "/school/lookup/email"}
    MeedApiFactory.post(args)

  return {
    getOauthData: getOauthData
    createAccount: createAccount
    createInfluencerAccount: createInfluencerAccount
    saveInfluencerExpertise: saveInfluencerExpertise
    emailSignup: emailSignup
    login: login
    verifyEmail: verifyEmail
    waitlistVerify: waitlistVerify
    waitlist_status: waitlist_status
    school_lookup: school_lookup
  }

SignupFactory.$inject = [
  "$http"
  "MeedApiFactory"
]

angular.module("meed").factory "SignupFactory", SignupFactory
