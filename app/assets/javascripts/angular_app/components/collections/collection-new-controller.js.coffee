CollectionNewController = (
  $scope,
  $routeParams,
  CONSTS,
  UTILS,
  CollectionsFactory) ->

  UTILS.setPageTitle("New Group")

  $scope.loading = true

  CollectionsFactory.getNewCollectionData().success (data) ->
    $scope.loading = false
    $scope.businessMajorTypes = data.business_major_types
    $scope.engineeringMajorTypes = data.engineering_major_types
    $scope.otherMajorTypes = data.other_major_types
    $scope.allMajorIds = data.all_major_ids

  $scope.allMajorsChecked = false
  $scope.CONSTS = CONSTS


  $scope.formData = {
    majorTypes: []
    title: $routeParams.title
  }


  $scope.checkAllMajors = () ->
    $scope.formData.majorTypes = $scope.allMajorIds

  $scope.uncheckAllMajors = () ->
    $scope.formData.majorTypes = []

  $scope.toggleAllMajors = (allMajorsChecked) ->
    if allMajorsChecked
      $scope.checkAllMajors()
    else
      $scope.uncheckAllMajors()

  $scope.loading = false

  $scope.someSelected = () ->
    $scope.formData.majorTypes.length > 0

  $scope.submitCreate = (formData, isValid) ->
    formData.submitted = true
    return unless isValid
    formData = $scope.formData
    data = {
      title:        formData.title
      description:  formData.description
      image_url:    formData.imageUrl
      is_private:    formData.isPrivate
      major_types:  formData.majorTypes
    }
    $scope.loading = true
    CollectionsFactory.createCollection(data).success (data) ->
      if data.success
        if data.redirect_url
          UTILS.redirect data.redirect_url
      else
        $scope.loading = false
        # Do something with an error message





CollectionNewController.$inject = [
  "$scope"
  "$routeParams"
  "CONSTS"
  "UTILS"
  "CollectionsFactory"
]

angular.module("meed").controller "CollectionNewController", CollectionNewController
