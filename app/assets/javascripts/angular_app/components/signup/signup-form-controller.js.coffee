SignupFormController = (
  $scope,
  $routeParams,
  $timeout,
  $cookies,
  $location,
  CONSTS,
  FORM_CONSTS,
  UTILS,
  VENDOR,
  FacebookFactory,
  SignupFactory,
  MajorsFactory,
  RedirectFactory,
  HeaderNavFactory) ->

  $scope.years = FORM_CONSTS.years
  $scope.formData = {
  }
  $scope.default_avatar = CONSTS.default_avatar
  $scope.emailSignupData = {}
  $scope.phoneNumberPattern = CONSTS.phone_number_pattern
  $scope.universityEmailPattern = CONSTS.university_email_pattern
  $scope.namePattern = CONSTS.name_pattern
  $scope.generalEmailPattern = CONSTS.general_email_pattern
  $scope.handlePattern = CONSTS.handle_pattern

  $scope.success = () ->
    console.log('Copied!')

  $scope.fail = (err) ->
    console.error('Error!', err)

  $closestModal = $("#signup-form").closest(".modal")
  if $closestModal.length == 0
    UTILS.center($("#signup-form"))
    $(window).resize ->
      UTILS.center($("#signup-form"))

  showStep = (step) ->
    signup_type = $cookies.get('signup-type')
    prefix = ''
    if signup_type == 'influencer'
      prefix = 'influencer-'

    $(".#{prefix}signup-form .step").hide()
    $(".#{prefix}signup-form .step.#{step}").show()
    if $closestModal.length == 0
      UTILS.center($("##{prefix}signup-form"))
      $(window).resize ->
        UTILS.center($("##{prefix}signup-form"))
    else
      $.modal.resize()

  $scope.authenticate = (provider) ->
    if provider == 'facebook'
      hideLogoTagline()
      showStep('create-account')
      UTILS.openModal("#signup-modal", {
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


  hideLogoTagline = () ->
    $(".logo-tagline-wrap").hide()

  showLogoTagline = () ->
    $(".logo-tagline-wrap").show()

  majorDegreesCb = (data) ->
    $scope.majors = data.majors
    $scope.degrees = data.degrees
    $timeout ->
      $("#signup-form select").selectize()
    , 300

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

  $scope.createAccount = (formData, isValid = true) ->
    formData.submitted = true
    formData.serverError = false
    return unless isValid
    $scope.loading = true
    referrer = $cookies.get("referrer")
    if referrer != null
      formData.referrer = referrer
    SignupFactory.createAccount(formData).success (data) ->
      $scope.loading = false
      if data.waitlist
        $scope.school_handle = data.school_handle
        hideLogoTagline()
        if data.success && data.verify_email
          showStep("waitlist-verify")
        else
          showStep("waitlist")
          # reopen modal with clickable outside
          UTILS.openModal("#signup-form", {clickClose: true, escapeClose: true, showClose: true})
      else if data.success && data.verify_email
        hideLogoTagline()
        showStep("verify-email")
      else if data.success && data.action == "waitlist"
        showWaitlist(data)
        UTILS.openModal("#signup-form", {clickClose: true, escapeClose: true, showClose: true})
      else if data.success && !data.verify_email
        UTILS.redirect(data.redirect_url)
      else if data.error
        $scope.serverError = data.error
        if data.handle
          formData.handle = data.handle
        if data.action == 'signin'
          $scope.serverError = true
          $scope.serverErrorMessage = data.error
          showStep("signup-login")
          showLogoTagline()
          UTILS.center($("#signup-form"))
        if data.redirect_url
          UTILS.redirect(data.redirect_url)
      RedirectFactory.setRedirectUrl(data.referrer_url)

  $scope.emailSignup = (emailSignupData, isValid = true) ->
    # emailSignupData.submitted = true
    # perform school lookup
    SignupFactory.school_lookup(emailSignupData.university_email).success (data) ->
      if data.school
        $scope.school = data.school
        emailSignupData.school_field = data.school.name
    return unless isValid
    hideLogoTagline()
    $(".university-email-wrap").hide()
    showStep("create-account")
    true

    # data = {email: emailSignupData.university_email}
    # SignupFactory.emailSignup(data).success (data) ->
    #   if data.waitlist
    #     $scope.school_handle = data.school_handle
    #     hideLogoTagline()
    #     showStep("waitlist")
    #   else if data.success && data.verify_email
    #     hideLogoTagline()
    #     showStep("verify-email")

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

  $scope.waitlistVerify = (data, isValid = true) ->
    data.submitted = true
    return unless isValid
    SignupFactory.waitlistVerify({token: data.token}).success (data) ->
      if data.success
        showWaitlist(data)
        UTILS.openModal("#signup-form", {clickClose: true, escapeClose: true, showClose: true})
      else
        $scope.serverError = data.error
        $timeout ->
          UTILS.redirect(data.redirect_url)
        , 3000

  MajorsFactory.getMajorsDegreesCache(majorDegreesCb)

  activateFromEmail = (email) ->
    if email
      if !email.endsWith(".edu") && !email.endsWith("waterloo.ca")
        $(".university-email-wrap").show()
      else
        $scope.formData["university_email"] = email
        $(".university-email-wrap").hide()
      $(".import-options").show()
      showStep("create-account")
      UTILS.openModal("#signup-modal")
      true
  activateFromEmailWithConfirmation = (email) ->
    if email
      if !email.endsWith(".edu") && !email.endsWith("waterloo.ca")
        $(".university-email-wrap").show()
      else
        $scope.formData["university_email"] = email
        $(".university-email-wrap").hide()
      $(".import-options").show()
      showStep("email-signup-confirmation")
      UTILS.openModal("#signup-modal")
      true

  showNeedMeedStatus = (email) ->
    if email
      hideLogoTagline()
      SignupFactory.waitlist_status(email).success (data) ->
        if data.success
          showWaitlist(data)
          UTILS.openModal("#signup-modal")
        else
          UTILS.redirect(data.redirect_url)

  $timeout ->
    if $routeParams.action == 'waitlist_status'
      if $routeParams.email
        showNeedMeedStatus($routeParams.email)
    else if $routeParams.action == 'signup'
      if $routeParams.type == 'influencer'
        UTILS.openModal("#influencer-signup-modal", {fixed: false})
      else
        UTILS.openModal("#signup-modal", {fixed: false})
    else if $routeParams.email
      if $routeParams.email.match(CONSTS.university_email_pattern)
        # get the school first
        SignupFactory.school_lookup($routeParams.email).success (data) ->
          if data.school
            $scope.school = data.school
            $scope.emailSignupData.school_field = data.school.name
        hideLogoTagline()
        activateFromEmailWithConfirmation($routeParams.email)
      else
        showStep("email-signup")
        UTILS.openModal("#signup-modal")

    if $routeParams.oauth_token
      hideLogoTagline()
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
    else
      $(".show-email-signup").click ->
        showStep("email-signup")

  VENDOR.loadFacebook()
  VENDOR.loadTwitter()


SignupFormController.$inject = [
  "$scope"
  "$routeParams"
  "$timeout"
  "$cookies"
  "$location"
  "CONSTS"
  "FORM_CONSTS"
  "UTILS"
  "VENDOR"
  "FacebookFactory"
  "SignupFactory"
  "MajorsFactory"
  "RedirectFactory"
  "HeaderNavFactory"
]

angular.module("meed").controller "SignupFormController", SignupFormController

