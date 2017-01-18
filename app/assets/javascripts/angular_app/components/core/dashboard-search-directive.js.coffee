dashboardSearch = (CONSTS, $timeout, MeedApiFactory) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/dashboard-search.html"
  replace: true
  link: ($scope, elem, attrs) ->
    $inputfield = $("#dash-search")
    $results = $("#dash-search-results")
    $clear = $(".search .clear")
    $close = $("#dash-search-results .close")
    searchUrl = "/dashboard/search/"
    searchCallback = (data, success) ->
      $scope.hits = {
        user: []
        job: []
        company: []
      }
      if data.results
        $scope.hits['user'] = data.results['users']
        $scope.hits['job'] = data.results['jobs']
        $scope.hits['company'] = data.results['companies']

    toggleResults = ($inputfield, $results) ->
      if $inputfield.val() == ""
        $results.hide()
        $clear.hide()
      else
        $results.show()
        $clear.show()
        url = searchUrl + encodeURIComponent($inputfield.val())
        MeedApiFactory.get({
          url: url,
          success: searchCallback
        })

    $results.click -> $results.hide()

    $clear.click ->
      $results.hide()
      $clear.hide()
      $inputfield.val("")

    $close.click -> $results.hide()

    $(document).on 'click', (e) ->
      if e.target.id != $inputfield.attr("id")
        $results.hide()

    $timeout ->
      $inputfield.keyup(
        -> toggleResults($inputfield, $results)
      ).focus(
        -> toggleResults($inputfield, $results)
      )
      # .blur(
      #   -> $results.hide()
      # )

    $scope.availableSearchParams = [
      { key: "job", name: "Job", placeholder: "Job Title ..." },
      { key: "user", name: "User", placeholder: "User Name..." },
      { key: "company", name: "Company", placeholder: "Company Name..." },
    ];

    $scope.$on('advanced-searchbox:modelUpdated', (event, model) ->
      $results.show()
      $clear.show()
      MeedApiFactory.post({url: searchUrl, data: model, success: searchCallback})
    )

dashboardSearch.$inject = [
  "CONSTS"
  "$timeout"
  "MeedApiFactory"
]

angular.module("meed").directive "dashboardSearch", dashboardSearch
