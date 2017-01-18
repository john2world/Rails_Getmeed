# Expects item to be passed in with id, comments
comments = (CONSTS, $timeout, UTILS) ->
  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/article/comments.html"
  replace: true
  scope:
    item: "="
    currentUser: "="
    showWriteComment: "="

  link: ($scope, elem, attrs) ->
    class windowManager
      constructor: (@max) ->
        if @max == 0
          @showingAmount = 0
          @showingBegin = 0
        else
          @showingAmount = if @max > 1 then 2 else 1
          @showingBegin = @max - @showingAmount

      hasMore: ->
        @showingAmount < @max

      showAll: ->
        @showingBegin = 0
        @showingAmount = @max

      enlarge: (size) ->
        @showingAmount += size
        if @showingBegin >= size
          @showingBegin -= size
        else
          @showingBegin = 0

      oneMoreElement: ->
        @max += 1
        @showingAmount += 1

      oneLessElement: ->
        @max -= 1
        if @showingBegin >= 1
          @showingBegin -= 1
        else
          @showingBegin = 0
    $timeout ->
      $scope.windowManager = new windowManager $scope.item.comments.length
      $scope.windowManager.showAll() if $scope.showWriteComment

    $scope.loadMoreComments = ->
      $scope.windowManager.enlarge 5

    $scope.$on "editComment", (event, comment) ->
      comment.editing = !comment.editing

    $scope.$on "deletedComment", (event, comment) ->
      $scope.windowManager.oneLessElement()
      UTILS.removeItemFromList(comment, $scope.item.comments)

    $scope.$on "submittedComment", (event, comment) ->
      $scope.windowManager.oneMoreElement()

    $scope.$on "confirmDeletion", (event, callback) ->
      $scope.confirmed = ->
        callback()
        $scope.windowManager.oneLessElement()
        $.modal.close()
      $scope.closeModal = ->
        $.modal.close()
      angular.element('#confirmation-modal').modal()

comments.$inject = [
  "CONSTS"
  "$timeout"
  "UTILS"
]

angular.module("meed").directive "comments", comments
