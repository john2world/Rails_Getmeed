htmlToPlaintext = () ->
  (text) ->
    String(text).replace(/<[^>]+>/gm, " ").replace(/\s+/g, " ")

underscoresToSpaces = () ->
  (text) ->
    String(text).replace(/_/g, " ").replace(/\s+/g, " ")

formatDateString = () =>
  (text) ->
    (new Date(text)).toLocaleDateString()

formatDateTimeStringFriendly = () =>
  (text) ->
    if text == null
      return text
    date = new Date(text)
    date_string = $.formatDateTime('M d', date)
    time_string = $.formatDateTime('g:ii a', date)
    return "#{date_string} @ #{time_string} PST"

trusted = ($sce) ->
  (url) ->
    $sce.trustAsResourceUrl url

titlecase = () ->
  (s) ->
    s = if s == undefined or s == null then '' else s
    s.toString().toLowerCase().replace /\b([a-z])/g, (ch) ->
      ch.toUpperCase()

truncateText = () ->
  (s) ->
    s = String(s)
    s = if s.length > 60 then String(s).substring(0, 50) + '...' else s

trusted.$inject = [
  "$sce"
]

maxFilter = () ->
  (values, max) ->
    if max
      values.filter (v) -> v <= max
    else
      values

minFilter = () ->
  (values, max) ->
    if max
      values.filter (v) -> v >= max
    else
      values



angular.module("meed")
  .filter("htmlToPlaintext", htmlToPlaintext)
  .filter("underscoresToSpaces", underscoresToSpaces)
  .filter("trusted", trusted)
  .filter("formatDateString", formatDateString)
  .filter("formatDateTimeStringFriendly", formatDateTimeStringFriendly)
  .filter("titlecase", titlecase)
  .filter('truncateText', truncateText)
  .filter('maxFilter', maxFilter)
  .filter('minFilter', minFilter)
