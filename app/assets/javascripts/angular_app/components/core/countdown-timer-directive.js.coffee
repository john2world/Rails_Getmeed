countdownTimer = ($timeout, CONSTS) ->

  linkFn = ($scope, elem, attrs) ->
    $timeout ->
      note = $("#countdown-note")
      ts = new Date($scope.date)
      newYear = false
      if new Date > ts
        # Notice the *1000 at the end - time must be in milliseconds
        ts = (new Date).getTime() + 10 * 24 * 60 * 60 * 1000
        newYear = false

      cb = false
      if note.length > 0
        cb = (days, hours, minutes, seconds) ->
          dayString     = days    + " day"    + (if days    == 1 then "" else "s")
          hourString    = hours   + " hour"   + (if hours   == 1 then "" else "s")
          minuteString  = minutes + " minute" + (if minutes == 1 then "" else "s")
          secondsString = seconds + " second" + (if seconds == 1 then "" else "s")
          message = "#{dayString}, #{hourString}, #{minuteString}, and #{secondsString} left to announce the winner!"
          note.html message

      $("#countdown").countdown
        timestamp: ts
        callback: cb

  restrict: "E"
  templateUrl: "#{CONSTS.components_dir}/core/countdown-timer.html"
  replace: false
  scope: {
    date: "@"
  }
  link: linkFn


countdownTimer.$inject = [
  "$timeout"
  "CONSTS"
]

angular.module("meed").directive "countdownTimer", countdownTimer
