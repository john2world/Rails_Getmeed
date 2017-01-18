# Just a factory for creating simple objects
StructFactory = () ->
  # https://gcanti.github.io/2014/09/25/six-reasons-to-define-constructors-with-only-one-argument.html
  build = (props, init = false, restricted = false) ->
    Struct = (obj) ->
      # make Struct idempotent
      return obj if obj instanceof Struct

      # make `new` optional, decomment if you agree
      # if (!(this instanceof Struct)) return new Struct(obj);

      if restricted
        # add props
        for name of props
          if props.hasOwnProperty(name)
            # here you could implement type checking exploiting props[name]
            @[name] = obj[name]
        # make the instance immutable, decomment if you agree
        # Object.freeze(this);
      else
        for name of obj
          @[name] = obj[name]

      init(this) if init # Run an optional init function that is passed in

      this

    # keep a reference to meta infos for further processing,
    # documentation tools and IDEs support
    Struct.meta = {props: props}
    Struct

  return {
    build: build
  }

# Use like this:
# Person = StructFactory.build(
#   name: String
#   surname: String)
# person = new Person(
#   surname: 'Canti'
#   name: 'Giulio')

StructFactory.$inject = [

]

angular.module("meed").factory "StructFactory", StructFactory
