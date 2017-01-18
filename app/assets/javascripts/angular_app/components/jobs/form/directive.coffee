jobForm = (CONSTS, $location, MeedApiFactory) ->
  ctrl = ($scope) ->
    $scope.addUniversity = (ele) ->
      $scope.job.schools = $scope.job.schools.concat [ele] unless $scope.job.schools.includes ele

    $scope.addMajor = (ele) ->
      $scope.job.majors = $scope.job.majors.concat [ele] unless $scope.job.majors.includes ele

    $scope.importJob = ->
      MeedApiFactory.post(url: "/jobs/import", data: { url: $scope.importUrl }).success (data) ->
        $scope.job.title = data.title
        $scope.job.description = data.description

    $scope.jobTypeOptions = [
      {
        "text": "Full Time (Experienced)"
        "value": "full_time_experienced"
      },
      {
        "text": "Full Time (Entry Level)"
        "value": "full_time_entry_level"
      },
      {
        "text": "Part Time (Hourly)"
        "value": "part_time"
      },
      {
        "text": "Internship"
        "value": "intern"
      }
    ]

    matchJob = (selectize) ->
      MeedApiFactory.get(url: "/jobs/match", data: $scope.job).success (data) ->
        $scope.matchCount = data.count

    $scope.jobTypeConfig =
      placeholder: 'Select Job Type (*)'
      maxItems: 1
      minItems: 1

    $scope.skillsOptions = []
    $scope.skillsConfig =
      plugins: ['remove_button']
      placeholder: 'Enter skills (*)'
      maxItems: 5
      minItems: 1
      onChange: matchJob

    $scope.schoolsOptions = []
    $scope.schoolsConfig =
      plugins: ['remove_button']
      placeholder: 'Select Universities (*)'
      maxItems: 30
      minItems: 1
      onChange: matchJob

    $scope.majorsOptions = []
    $scope.majorsConfig =
      plugins: ['remove_button']
      placeholder: 'Select Majors (*)'
      maxItems: 30
      minItems: 1
      optgroups: []
      render:
        optgroup_header: (data, escape) ->
          '<div class="optgroup-header">' + escape(data.text) + '</div>'
      onChange: matchJob

    $scope.chargeJob = (price) ->
      $scope.paid = false
      handler = StripeCheckout.configure(
        key: "pk_ktMbiAhYGulwQ9OsWCSIkdfF6jagV",
        image: 'https://res.cloudinary.com/resume/image/upload/c_scale,w_100/v1427867425/Screen_Shot_2015-03-31_at_10.50.05_PM_plutej.png',
        token: (token) ->
          $scope.charging = false
          $scope.paid = true
          $scope.stripeToken = token.id
          $scope.stripeEmail = token.email
          $scope.$apply()
      )

      handler.open(
        name: 'Meed Inc',
        description: 'Job Posting on Meed Inc.',
        amount: price
      )

    $scope.submitJob = (job) ->
      return if $scope.jobForm.$invalid

      success = (data) ->
        $location.path "/jobs/manage"

      if job._id
        MeedApiFactory.put(
          url: "/jobs/#{job._id}"
          data: job
        ).success(success)
      else
        MeedApiFactory.post(
          url: "/jobs"
          data:
            job: job
            stripeToken: $scope.stripeToken
            stripeEmail: $scope.stripeEmail
        ).success(success)

  ctrl.$inject = [
    "$scope"
  ]

  return {
    restrict: "E"
    templateUrl: "#{CONSTS.components_dir}/jobs/form/view.html"
    replace: false
    scope:
      job: "="
    controller: ctrl
    link: ($scope, elem, attrs) ->
      MeedApiFactory.get("/jobs/new").success (data) ->
        $scope.loaded = true

        $scope.extraMajors = data.majors.filter (major) ->
          major.optgroup == 'major_groups'

        data.skills.map (sk) ->
          $scope.skillsOptions.push {text: sk, value: sk}

        data.schools.map (ele) ->
          $scope.schoolsOptions.push ele

        data.majorOptionGroups.map (ele) ->
          $scope.majorsConfig.optgroups.push ele

        data.majors.map (ele) ->
          $scope.majorsOptions.push ele
  }

jobForm.$inject = [
  "CONSTS"
  "$location"
  "MeedApiFactory"
]

angular.module("meed").directive "jobForm", jobForm
