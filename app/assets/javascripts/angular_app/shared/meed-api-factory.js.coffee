# Just a factory for making simple API requests to DRY up some common options
# Done here instead of overriding $httpProvider headers directly because that's
# too much

MeedApiFactory = ($http, UTILS) ->
  # default_success = (data, status, headers, config) ->
  #   true
  #   # console.log "SUCCESS"

  default_error = (data, status, headers, config) ->
    console.log "ERROR: #{data.error}"
    console.log headers
    UTILS.redirect(data.redirect_url) if data.redirect_url


  default_headers = {
    "Content-Type": "application/json"
    "Accept": "application/json"
  }

  httpWithDefaults = (args) ->
    success = args.success
    error = args.error
    delete args.success
    delete args.error
    ret = $http(args)
    ret.success(success) if success
    ret.error(error) if error
    ret

  wrappedHttp = (method, args) ->
    # Can just pass in URL as a short form, using all other defaults
    args = {url: args} if typeof(args) == "string"
    # args.data ||= {}
    # args.success ||= default_success
    args.error ||= default_error
    args.headers ||= default_headers
    args.method = method
    httpWithDefaults(args)

  zdelete  = (args) -> wrappedHttp("DELETE", args)
  get      = (args) -> wrappedHttp("GET", args)
  patch    = (args) -> wrappedHttp("PATCH", args)
  post     = (args) -> wrappedHttp("POST", args)
  put      = (args) -> wrappedHttp("PUT", args)
  head     = (args) -> wrappedHttp("HEAD", args)
  jsonp    = (args) -> wrappedHttp("JSONP", args)

  return {
    delete: zdelete
    get: get
    head: head
    jsonp: jsonp
    patch: patch
    post: post
    put: put
  }


MeedApiFactory.$inject = [
  "$http"
  "UTILS"
]

angular.module("meed").factory "MeedApiFactory", MeedApiFactory
