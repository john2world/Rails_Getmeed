applicant = (MeedApiFactory, ModalService, CONSTS, CurrentUserFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/jobs/applicant/applicant.html"
  replace: true
  scope:
    applicant: '='
    tab: '='
  link: ($scope, elem, attrs) ->
    $scope.applicant.id ||= $scope.applicant.handle + '_' + $scope.applicant.job._id

    $scope.applicant.story = if applicant.answer
        $scope.applicant.answer.description
      else if applicant.cover_note
        $scope.applicant.cover_note
      else if $scope.applicant.profile
        $scope.applicant.profile.summary || $scope.applicant.profile.objective

    $scope.profile = (applicant) ->
      if $scope.tab == 'applications'
        MeedApiFactory.get("/job_applicants/#{applicant.id}")

    $scope.contact = (applicant) ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/jobs/applicant/contact.html"
        controller: "ModalsJobContact"
        inputs:
          applicant: applicant
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
        )
      )

    $scope.shortList = (applicant) ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/jobs/applicant/shortlist.html"
        controller: "ModalsJobShortlist"
        inputs:
          applicant: applicant
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
        )
      )

    CurrentUserFactory.getCurrentUser().success (data) ->
      $scope.currentUser = data if data.success

    $scope.invite = (applicant) ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/jobs/applicant/invite.html"
        controller: "ModalsJobInvite"
        inputs:
          applicant: applicant
          currentUser: $scope.currentUser
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
        )
      )

    $scope.notes = (applicant) ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/jobs/applicant/note.html"
        controller: "ModalsJobNote"
        inputs:
          applicant: applicant
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
        )
      )

    $scope.archive = (applicant) ->
      ModalService.showModal(
        templateUrl: "#{CONSTS.components_dir}/jobs/applicant/archive.html"
        controller: "ModalsJobArchive"
        inputs:
          applicant: applicant
      ).then((modal) ->
        modal.element.modal()
        modal.close.then((confirmed) ->
          $.modal.close()
          $scope.$emit("archivedApplicant", applicant) if confirmed
        )
      )

applicant.$inject = [
  "MeedApiFactory"
  "ModalService"
  "CONSTS"
  "CurrentUserFactory"
]

angular.module("meed").directive "applicant", applicant
