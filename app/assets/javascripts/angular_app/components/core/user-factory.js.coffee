UserFactory = ($http) ->



  name = () ->
    return "" if !(@first_name || @last_name)
    return @first_name unless @last_name
    return @last_name unless @first_name
    return (first_name + last_name).titleize



UserFactory.$inject = [
  "$http"
]

angular.module("meed").factory "UserFactory", UserFactory
