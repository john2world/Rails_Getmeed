# Adding some functions to the Array prototype
if typeof Array::unique != "function"
  Array::unique = ->
    @reduce ((accum, current) ->
      if accum.indexOf(current) < 0
        accum.push current
      accum
    ), []

if typeof Array::indexOf != "function"
  Array::indexOf = (needle) ->
    i = 0
    while i < @length
      if @[i] == needle
        return i
      i++
    -1