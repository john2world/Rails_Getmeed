
angular.module "meed", [
  "ngRoute"
  "ngResource"
  "templates"  # For angular rails templates gem and proper routing
  "ngAnimate"  # For animations
  "ngSanitize" # Sanitizing HTML output
  "gist-embed" # Embedding gists from github
  "checklist-model" # array of checkboxes
  "ngFacebook"
  "ngMessages"
  "ngCookies"
  "angular-clipboard"
  "ngTextTruncate"
  "720kb.tooltips"
  "720kb.socialshare"
  "angular-advanced-searchbox"
  "tagged.directives.infiniteScroll"
  "angularModalService"
  "selectize"
  'material.components.tabs'
  'material.components.dialog'
  'material.components.button'
  'material.components.card'
]

routeConfig = ($routeProvider, CONSTS) ->
  $routeProvider.when("/",
    templateUrl: "#{CONSTS.components_dir}/home/index.html"
    controller: "HomeController"
  ).when("/influencers",
    templateUrl: "#{CONSTS.components_dir}/influencers/index.html"
    controller: "InfluencersController"

  ).when("/recruiting",
    templateUrl: "#{CONSTS.components_dir}/home/recruiter_landing.html"

  ).when("/home/index",
    templateUrl: "#{CONSTS.components_dir}/home/index.html"
    controller: "HomeController"

  ).when("/job/:jobSlug",
    templateUrl: "#{CONSTS.components_dir}/jobs/show.html"
    controller: "JobController"

  ).when("/submit/post/:collectionId",
    templateUrl: "#{CONSTS.components_dir}/collections/user-collections.html"
    controller: "UserCollectionsController"

  ).when("/jobs/:id/edit",
    templateUrl: "#{CONSTS.components_dir}/jobs/edit/view.html"
    controller: "JobsEditController"

  ).when("/job_applicants",
    templateUrl: "#{CONSTS.components_dir}/jobs/applications/index/view.html"
    controller: "JobsApplicationsIndexController"

  ).when("/jobs/manage",
    templateUrl: "#{CONSTS.components_dir}/jobs/manage/view.html"
    controller: "JobsManageController"

  ).when("/jobs/new",
    templateUrl: "#{CONSTS.components_dir}/jobs/new/view.html"
    controller: "JobsNewController"

  ).when("/jobs/:slug",
    templateUrl: "#{CONSTS.components_dir}/jobs/jobs-browse.html"
    controller: "JobsBrowseController"

  ).when("/categories/:categorySlug",
    templateUrl: "#{CONSTS.components_dir}/collections/collections-browse.html"
    controller: "CollectionsBrowseController"

    # templateUrl: "#{CONSTS.components_dir}/collections/categories/collection-category.html"
    # controller: "CollectionCategoryController"

  ).when("/collections/new/:categorySlug?",
    templateUrl: "#{CONSTS.components_dir}/collections/new.html"
    controller: "CollectionNewController"

  ).when("/feed/tag/:tagId",
    templateUrl: "#{CONSTS.components_dir}/tags/tag.html"
    controller: "TagsController"

  ).when("/collection/:slug_id/:collectionId",
    templateUrl: "#{CONSTS.components_dir}/collections/collection.html"
    controller: "CollectionController"

  ).when("/:handle/ama/:event_id",
    templateUrl: "#{CONSTS.components_dir}/profile/show.html"
    controller: "ProfileController"

  ).when("/:id/collection/:slug_id/:collectionId",
    templateUrl: "#{CONSTS.components_dir}/collections/collection.html"
    controller: "CollectionController"

  ).when("/contact",
    templateUrl: "#{CONSTS.components_dir}/contact/contact.html"
    controller: "ContactController"
  ).when("/legal/tos",
    templateUrl: "#{CONSTS.components_dir}/legal/legal.html"
    controller: "LegalController"
  ).when("/settings",
    templateUrl: "#{CONSTS.components_dir}/settings/settings.html"
    controller: "SettingsController"

  ).when("/ineedmeed",
    templateUrl: "#{CONSTS.components_dir}/comingsoon/index.html"
    controller: "ComingSoonController"

  ).when("/company/edit",
    templateUrl: "#{CONSTS.components_dir}/company/edit/view.html"
    controller: "CompanyEditController"

  ).when("/company/:companySlug",
    templateUrl: "#{CONSTS.components_dir}/company/company.html"
    controller: "CompanyController"

  ).when("/leaderboard/show",
    redirectTo: "/?lb=1"

  ).when("/:id/:year/:month/:day/:article_id",
    templateUrl: "#{CONSTS.components_dir}/article/show.html"
    controller: "ArticleController"

  ).when("/ama/:ama_id",
    templateUrl: "#{CONSTS.components_dir}/ama/show.html"
    controller: "AmaController"

  ).when("/:handle",
    templateUrl: "#{CONSTS.components_dir}/profile/show.html"
    controller: "ProfileController"

  ).when("/stories/new",
    templateUrl: "#{CONSTS.components_dir}/stories/new.html"
    controller: "StoriesNewController"

  ).when("/:handle/stories/:slug",
    templateUrl: "#{CONSTS.components_dir}/stories/show.html"
    controller: "StoriesShowController"

  ).when("/stories/:slug/edit",
    templateUrl: "#{CONSTS.components_dir}/stories/edit.html"
    controller: "StoriesEditController"

  ).otherwise redirectTo: "/"

  # .when("/article/new", # Not urrently used since we use meed posts
  #   templateUrl: "#{CONSTS.components_dir}/article/new.html"
  #   controller: "ArticleController"
  # )


  # .when("/messages",
  #   templateUrl: "views/messages/index.html"
  #   controller: "MessagesController"
  # ).when("/insights",
  #   templateUrl: "views/insights/index.html"
  #   controller: "InsightsController"
  # .when("/contact",
  #   templateUrl: "views/contact/index.html"
  #   controller: "ContactController"
  # )

setupCsrfHeaders = ($httpProvider) ->
  ############################################################################
  # Workaround to get Rails CSRF token into request headers
  # http://stackoverflow.com/questions/14734243/rails-csrf-protection-angular-js-protect-from-forgery-makes-me-to-log-out-on#answer-14735207
  csrfToken = $('meta[name=csrf-token]').attr('content')
  $httpProvider.defaults.headers["post"]['X-CSRF-Token']   = csrfToken
  $httpProvider.defaults.headers["put"]['X-CSRF-Token']    = csrfToken
  $httpProvider.defaults.headers["patch"]['X-CSRF-Token']  = csrfToken

meedConfig = ($routeProvider,
              $httpProvider,
              $locationProvider,
              $facebookProvider,
              CONSTS) ->
  routeConfig($routeProvider, CONSTS)
  setupCsrfHeaders($httpProvider)
  $facebookProvider.setAppId '219288138250944'
  $locationProvider.html5Mode({
    enabled: true
    requireBase: false
  })


meedConfig.$inject = [
  "$routeProvider"
  "$httpProvider"
  "$locationProvider"
  "$facebookProvider"
  "CONSTS"
]

# Allows us to sometimes change the path without reloading
# http://joelsaupe.com/programming/angularjs-change-path-without-reloading/
meedRun = ($route, $rootScope, $location) ->
  original = $location.path
  $location.path = (path, reload) ->
    if reload == false
      lastRoute = $route.current
      un = $rootScope.$on('$locationChangeSuccess', ->
        $route.current = lastRoute
        un()
      )
    original.apply $location, [ path ]
  # Get the first script element, which we'll use to find the parent node
  firstScriptElement = document.getElementsByTagName('script')[0]
  # Create a new script element and set its id
  facebookJS = document.createElement('script')
  facebookJS.id = 'facebook-jssdk'
  # Set the new script's source to the source of the Facebook JS SDK
  facebookJS.src = '//connect.facebook.net/en_US/sdk.js'
  # Insert the Facebook JS SDK into the DOM
  firstScriptElement.parentNode.insertBefore facebookJS, firstScriptElement
  return

meedRun.$inject = [
  "$route"
  "$rootScope"
  "$location"
]


angular.module("meed").config meedConfig

angular.module("meed").run meedRun

