# Adding some functions to the String prototype

fnType = "function"

if typeof String::startsWith != fnType
  String::startsWith = (str) ->
    @slice(0, str.length) == str

if typeof String::endsWith != fnType
  String::endsWith = (str) ->
    @slice(-str.length) == str

if typeof String::titleize != fnType
  String::titleize = ->
    words = @split(' ')
    ret = []
    i = 0
    while i < words.length
      ret.push words[i].charAt(0).toUpperCase() + words[i].toLowerCase().slice(1)
      ++i
    ret.join ' '
