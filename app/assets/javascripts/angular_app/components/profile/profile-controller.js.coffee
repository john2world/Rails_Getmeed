ProfileController = (
    $scope,
    $location,
    $routeParams,
    UTILS,
    CONSTS,
    FORM_CONSTS,
    CollectionFactory,
    CollectionsFactory,
    ActivityFeedItemFactory,
    HeaderNavFactory,
    CompanyFactory,
    ProfileFactory,
    ProfileUserFactory,
    ProfileEducationFactory,
    ProfileCourseProjectFactory,
    ProfilePublicationFactory,
    ProfileInternshipFactory,
    ProfileExperienceFactory,
    ProfileEditTabFactory,
    CurrentUserFactory
  ) ->

  $scope.months = FORM_CONSTS.months
  $scope.years = FORM_CONSTS.years
  $scope.semesters = FORM_CONSTS.semesters
  $scope.tab = ProfileEditTabFactory
  $scope.companies_loading = true

  tabId = $location.absUrl().split("#")[1]
  if tabId == 'portfolio'
    $scope.loading = true

  setupProfile = (data) ->
    # TODO: move these to a Profile instantiable class

    data.user = new ProfileUserFactory(data.user)
    UTILS.setPageTitle("#{data.user.first_name} Profile")

    if data.activity_feed_items
      $scope.feedItems = data.activity_feed_items.map (e) ->
        new ActivityFeedItemFactory(e)

    if data.event_feed_items
      $scope.eventFeedItems = data.event_feed_items

    $scope.is_event_happening = data.is_event_happening

    if data.event
      $scope.event = data.event

    if data.portfolio_feed_items
      $scope.portfolioFeedItems = data.portfolio_feed_items

    # if data.is_viewer_profile
    if data.educations
      data.educations = data.educations.map( (e) ->
        new ProfileEducationFactory(e)
      )

    if data.courses
      data.courses = data.courses.map( (e) ->
        new ProfileCourseProjectFactory(e)
      )

    if data.publications
      data.publications = data.publications.map( (e) ->
        new ProfilePublicationFactory(e)
      )

    if data.internships
      data.internships = data.internships.map( (e) ->
        new ProfileInternshipFactory(e)
      )

    if data.experiences
      data.experiences = data.experiences.map( (e) ->
        new ProfileExperienceFactory(e)
      )

    if data.collections and data.collections.length > 0
      $scope.hasCollections = true
      data.collections = data.collections.map (e) ->
        new CollectionFactory(e)


    if data.followed_collections and data.followed_collections.length > 0
      $scope.hasCollections = true
      data.followed_collections = data.followed_collections.map (e) ->
        new CollectionFactory(e)

    data



  $scope.generateUserImageText = (user) ->
      return user.first_name.charAt(0) + user.last_name.charAt(0)

  # Returns true if we should show a given edit form
  $scope.showEdit = (section) ->
    # console.log section
    # console.log $scope.tab
    $scope.tab.isSet(section)

  $scope.backupUser = () ->
    $scope.userBackup = UTILS.clone($scope.profile.user)

  $scope.restoreUserBackup = () ->
    $scope.profile.user = $scope.userBackup

  $scope.backupObjective = () ->
    $scope.objectiveBackup = $scope.profile.objective + ""

  $scope.restoreObjectiveBackup = () ->
    $scope.profile.objective = $scope.objectiveBackup

  # Just organizing functions related to User Header
  # TODO: move to header directive code
  $scope.headerFns = {
    edit: (item) ->
      item.openEdit()
      item.backup()

    closeEdit: (item, revert = false) ->
      if revert
        item.restoreBackup()
      item.closeEdit()

    submitSave: (item, valid = true) ->
      item.submitted = true
      return unless valid
      success = () -> $scope.headerFns.closeEdit(item)
      return item.save(success)
  }

  # TODO: move this
  $scope.editObjective = () ->
    $scope.tab.setTab("objective")
    $scope.backupObjective()

  $scope.closeEditObjective = (revert = false) ->
    $scope.restoreObjectiveBackup() if revert
    $scope.tab.setTab("objective", false)

  submitUpdateObjective = () ->
    data = {
      objective: {text: $scope.profile.objective}
    }
    return ProfileFactory.updateObjective(data, () ->
      CurrentUserFactory.updateCurrentUser($scope)
      $scope.closeEditObjective()
    )


  $scope.follow = () ->
    ProfileFactory.followUser($scope.profile.user.handle).success (data) ->
      $scope.profile.is_viewer_following = true
      $scope.isFollowing = true

  $scope.unfollow = () ->
    ProfileFactory.unfollowUser($scope.profile.user.handle).success (data) ->
      $scope.profile.is_viewer_following = false
      $scope.isFollowing = false


  $scope.submitUpdateObjective = submitUpdateObjective

  # TODO: move this
  $scope.editHeadline = () ->
    $scope.tab.setTab("headline")
    $scope.backupUser()

  $scope.closeEditHeadline = (revert = false) ->
    $scope.restoreUserBackup() if revert
    $scope.tab.setTab("headline", false)

  $scope.editBio = () ->
    $scope.tab.setTab("bio")
    $scope.backupUser()

  $scope.editPreviousCompany = () ->
    $scope.tab.setTab("previous-companies")
    $scope.backupUser()

  $scope.closePreviousCompany = (revert = false) ->
    $scope.restoreUserBackup() if revert
    $scope.tab.setTab("previous-companies", false)

  $scope.editCurrentCompany = () ->
    $scope.tab.setTab("current-company")
    $scope.backupUser()

  $scope.closeCurrentCompany = (revert = false) ->
    $scope.restoreUserBackup() if revert
    $scope.tab.setTab("current-company", false)

  $scope.closeBio = (revert = false) ->
    $scope.restoreUserBackup() if revert
    $scope.tab.setTab("bio", false)

  submitUpdateBio = () ->
    data = {
      bio: {text: $scope.profile.user.bio}
    }
    ProfileFactory.updateBio(data, () ->
      CurrentUserFactory.updateCurrentUser($scope)
      $scope.closeBio()
    )

  submitUpdateCurrentCompany = () ->
    data = {
      company_id: $scope.formData.company_id
    }

    ProfileFactory.updateCurrentCompany(data).success (data) ->
      $scope.profile.user.current_company = data.name
      CurrentUserFactory.updateCurrentUser($scope)
      $scope.closeCurrentCompany()

  submitUpdatePreviousCompany = () ->
    data = {
      company_ids: $scope.formData.company_ids
    }
    console.log($scope.formData.company_ids)
    ProfileFactory.updatePreviousCompany(data).success (data) ->
      $scope.profile.user.company_names = data.company_names
      CurrentUserFactory.updateCurrentUser($scope)
      $scope.closePreviousCompany()

  submitUpdateHeadline = () ->
    data = {
      headline: {text: $scope.profile.user.headline}
    }
    ProfileFactory.updateHeadline(data, () ->
      CurrentUserFactory.updateCurrentUser($scope)
      $scope.closeEditHeadline()
    )

  $scope.submitUpdateHeadline = submitUpdateHeadline
  $scope.submitUpdateBio = submitUpdateBio
  $scope.submitUpdateCurrentCompany = submitUpdateCurrentCompany
  $scope.submitUpdatePreviousCompany = submitUpdatePreviousCompany


  editFns = (klass, list) ->
    add = () ->
      data = {
        _id:      UTILS.randString()
        newEntry: true
      }
      item = new klass(data)
      # console.log "add"
      list.unshift(item)
      edit(item)


    del = (item) ->
      item.del() unless item.newEntry
      removeFromList(item)

    edit = (item) ->
      item.openEdit()
      item.backup()

    closeEdit = (item, revert = false) ->
      if revert
        item.restoreBackup()
        removeFromList(item) if item.newEntry
      item.closeEdit()

    removeFromList = (item) ->
      UTILS.removeItemFromList(item, list, "_id")
      # update user after this
      CurrentUserFactory.updateCurrentUser($scope)

    submitSave = (item, isValid = true) ->
      item.submitted = true
      return unless isValid
      success = () ->
        CurrentUserFactory.updateCurrentUser($scope)
        closeEdit(item)
      if item.newEntry
        success = (data) ->
          CurrentUserFactory.updateCurrentUser($scope)
          closeEdit(item)
          item._id = data._id
          item.newEntry = false
      item.save(success)

    return {
      add: add
      del: del
      edit: edit
      closeEdit: closeEdit
      removeFromList: removeFromList
      submitSave: submitSave
    }

  setupProfileEdit = ($s) ->
    $s.profile.courses ||= []
    $s.profile.publications ||= []
    $s.profile.educations ||= []
    $s.profile.internships ||= []
    $s.profile.experiences ||= []
    $s.courseFns = editFns( ProfileCourseProjectFactory, $s.profile.courses)
    $s.publicationFns = editFns(ProfilePublicationFactory, $s.profile.publications)
    $s.educationFns = editFns(ProfileEducationFactory, $s.profile.educations)
    $s.internshipFns = editFns(ProfileInternshipFactory, $s.profile.internships)
    $s.experienceFns = editFns(ProfileExperienceFactory, $s.profile.experiences)

  # TODO: move to directive
  $scope.showTab = (tabId) ->
    $(".tab").hide()
    $("##{tabId}").fadeIn()
    $(".tab-nav a").removeClass("active")
    $("#show-#{tabId}").addClass("active")
    true
  $scope.hasCollections = false
  ProfileFactory.getProfile($routeParams.handle, $routeParams.showRajni).success (data) ->
    if data.user.badge == 'influencer'
      HeaderNavFactory.setInfluencer(true)
      CompanyFactory.getAllCompanies().success (data) ->
        $scope.companies = data.companies
        if data.companies
          $scope.companies_loading = false
    else
      HeaderNavFactory.setBgHidden(false)


    $scope.profile = setupProfile(data)
    $scope.isFollowing = data.is_viewer_following
    $scope.showFollow = true
    if $scope.currentUser && $scope.profile.user.handle == $scope.currentUser.handle
      $scope.showFollow = false

    if tabId == "portfolio"
      $scope.showTab("#{tabId}-tab")
    else if tabId == "ama"
      $scope.showTab("#{tabId}-tab")
    else if tabId == "collections"
      $scope.showTab("#{tabId}-tab")
    else
      $scope.showTab("profile-tab")

    if $scope.profile.is_viewer_profile
      setupProfileEdit($scope)

    user = $scope.profile.user
    UTILS.setPageTitle("#{user.first_name} #{user.last_name}")


ProfileController.$inject = [
  "$scope"
  "$location"
  "$routeParams"
  "UTILS"
  "CONSTS"
  "FORM_CONSTS"
  "CollectionFactory"
  "CollectionsFactory"
  "ActivityFeedItemFactory"
  "HeaderNavFactory"
  "CompanyFactory"
  "ProfileFactory"
  "ProfileUserFactory"
  "ProfileEducationFactory"
  "ProfileCourseProjectFactory"
  "ProfilePublicationFactory"
  "ProfileInternshipFactory"
  "ProfileExperienceFactory"
  "ProfileEditTabFactory"
  "CurrentUserFactory"
]

angular.module("meed").controller "ProfileController", ProfileController


