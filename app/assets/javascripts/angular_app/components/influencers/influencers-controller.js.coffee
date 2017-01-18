InfluencersController = (
  $scope,
  $routeParams,
  $timeout,
  $cookies,
  CONSTS,
  FORM_CONSTS,
  UTILS,
  VENDOR,
  CollectionsFactory,
  CompanyFactory,
  FacebookFactory,
  SignupFactory,
  HeaderNavFactory,
  MeedApiFactory,
  RedirectFactory) ->

  $scope.years = FORM_CONSTS.years
  $scope.formData = {
    image_url: CONSTS.default_avatar
  }
  $scope.emailSignupData = {}
  if $routeParams.lb or $routeParams.oauth_token
    $scope.regFlow = true
  else
    $scope.regFlow = false

  $scope.phoneNumberPattern = CONSTS.phone_number_pattern
  $scope.universityEmailPattern = CONSTS.university_email_pattern
  $scope.namePattern = CONSTS.name_pattern
  $scope.generalEmailPattern = CONSTS.general_email_pattern
  $scope.handlePattern = CONSTS.handle_pattern
  RedirectFactory.setInfluencerAuthFlow()

  HeaderNavFactory.setBgHidden(true)
  HeaderNavFactory.setInfluencer(true)
  CollectionsFactory.getNewCollectionData().success (data) ->
    $scope.loading = false
    $scope.businessMajorTypes = data.business_major_types
    $scope.engineeringMajorTypes = data.engineering_major_types
    $scope.otherMajorTypes = data.other_major_types
    $scope.allMajorIds = data.all_major_ids
    $scope.categories = data.categories

  $scope.success = () ->
  $scope.fail = (err) ->
    console.error('Error!', err)
  $closestModal = $("#influencer-signup-form").closest(".modal")
  if $closestModal.length == 0
    UTILS.center($("#influencer-signup-form"))
    $(window).resize ->
      UTILS.center($("#influencer-signup-form"))

  showStep = (step) ->
    $(".influencer-signup-form .step").hide()
    $(".influencer-signup-form .step.#{step}").show()
    if $closestModal.length == 0
      UTILS.center($("#influencer-signup-form"))
      $(window).resize ->
        UTILS.center($("#influencer-signup-form"))
    else
      $.modal.resize()
      UTILS.center($("#influencer-signup-form"))

  $scope.authenticate = (provider) ->
    if provider == 'facebook'
      hideLogoTagline()
      showStep('create-account')
      UTILS.openModal("#influencer-signup-form", {
        fixed: false, clickClose: false, escapeClose: false,
        showClose: false
      })
      $scope.loading = true
      user_promise = FacebookFactory.getUserInformation()
      user_promise.then (result) ->
        $scope.loading = false
        $scope.formData['first_name'] = result['first_name']
        $scope.formData['last_name'] = result['last_name']
        $scope.formData['image_url'] = result['picture']
        $scope.formData['primary_email'] = result['email']
    else

    return

  $scope.schoolsOptions = []
  $scope.undergraduateSchoolConfig =
    labelField: "name"
    valueField: "handle"
    searchField: [
      'name'
    ]
    placeholder: 'Undergraduate University (*)'
    maxItems: 1
    minItems: 1

  $scope.graduateSchoolConfig =
    labelField: "name"
    valueField: "handle"
    searchField: [
      'name'
    ]
    placeholder: 'Graduate University (optional)'
    maxItems: 3

  MeedApiFactory.get("/schools").success (data) ->
    data.schools.map (ele) ->
      $scope.schoolsOptions.push ele

  hideLogoTagline = () ->
    $(".logo-tagline-wrap").hide()

  showLogoTagline = () ->
    $(".logo-tagline-wrap").show()

  showWaitlist = (data) ->
    hideLogoTagline()
    $scope.waitlistNo = data.waitlist_no
    $scope.handle = data.handle
    $scope.email = data.email
    $scope.campaign_type = data.campaign_type
    $scope.referral_url = data.invite_url
    showStep("waitlist-status")
    # initializing the fb send
    $(".waitlist-status > .fb-send.wrapper-button").click ->
      FB.ui({
        method: 'send',
        link: $scope.referral_url
      })

  $scope.saveExpertise = (formData, isValid = true) ->
    formData.submitted = true
    formData.serverError = false
    return unless isValid
    $scope.loading = true
    SignupFactory.saveInfluencerExpertise(formData).success (data) ->
      $scope.loading = false
      UTILS.redirect(data.redirect_url)
  $scope.createAccount = (formData, isValid = true) ->
    formData.submitted = true
    formData.serverError = false
    return unless isValid
    $scope.loading = true
    SignupFactory.createInfluencerAccount(formData).success (data) ->
      $scope.loading = false
      $scope.school_handle = data.school_handle
      hideLogoTagline()
      showStep("expertise")

  $scope.emailSignup = (emailSignupData, isValid = true) ->
    return unless isValid
    hideLogoTagline()
    $(".university-email-wrap").hide()
    showStep("create-account")
    true

  $scope.login = (loginData, isValid = true) ->
    loginData.submitted = true
    return unless isValid
    data = {
      username: loginData.username
      password: loginData.password
    }
    $scope.loading = true
    SignupFactory.login(data).success (data) ->
      $scope.loading = false
      if data.success
        UTILS.redirect(data.redirect_url)
      else
        $scope.serverError = true
        if data.error == "accountDoesntExistCreate"
          $scope.serverErrorMessage = "Account doesn't exist. Please signup or activate."
        else
          $scope.serverErrorMessage = "Login incorrect, please try again."

  $scope.verifyEmail = (data, isValid = true) ->
    data.submitted = true
    return unless isValid
    SignupFactory.verifyEmail({token: data.token}).success (data) ->
      if data.success
        UTILS.redirect(data.redirect_url)
      else
        $scope.serverError = data.error
        $timeout ->
          UTILS.redirect(data.redirect_url)
        , 3000

  activateFromEmail = (email) ->
    if email
      hideLogoTagline()
      if !email.endsWith(".edu") && !email.endsWith("waterloo.ca")
        $(".university-email-wrap").show()
      else
        $scope.formData["university_email"] = email
        $(".university-email-wrap").hide()
      $(".import-options").show()
      showStep("create-account")
      UTILS.openModal("#influencer-signup-form")
      true

  showNeedMeedStatus = (email) ->
    if email
      hideLogoTagline()
      SignupFactory.waitlist_status(email).success (data) ->
        if data.success
          showWaitlist(data)
          UTILS.openModal("#influencer-signup-form")
        else
          UTILS.redirect(data.redirect_url)

  $timeout ->
    if $routeParams.oauth_token
      hideLogoTagline()
      signup_type = $cookies.get('signup-type')
      if signup_type == 'influencer'
        showStep("create-account")
        $scope.loading = true
        SignupFactory.getOauthData($routeParams.oauth_token).success (data) ->
          $scope.loading = false
          if data.success
            $scope.oauthData = data
            for k in ["first_name", "last_name", "image_url", "primary_email", "handle"]
              do (k) ->
                $scope.formData[k] = data[k]
          else
            UTILS.redirect(data.redirect_url)
          $.modal.resize()
        UTILS.openModal("#influencer-signup-form", {
          fixed: false, clickClose: false, escapeClose: false,
          showClose: false
        })
    else
      $(".show-email-signup").click ->
        showStep("email-signup")

  VENDOR.loadFacebook()
  VENDOR.loadTwitter()


InfluencersController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "$cookies"
  "CONSTS"
  "FORM_CONSTS"
  "UTILS"
  "VENDOR"
  "CollectionsFactory"
  "CompanyFactory"
  "FacebookFactory"
  "SignupFactory"
  "HeaderNavFactory"
  "MeedApiFactory"
  "RedirectFactory"
]

angular.module("meed").controller "InfluencersController", InfluencersController

