ProfilePublicationFactory = (StructFactory, ProfileModelPrototype) ->

  props = {
    _id: String
    description: String
    handle: String
    kudos_count: Number
    link: String
    start_date: String
    title: String
    year: String
  }

  ProfilePublication = StructFactory.build(props)
  # Instance fields and methods go here
  instanceMethods = {
    class: () -> ProfilePublication
    saveUrl: () -> "/profiles/publication/save"
    dataForApi: () ->
      id = @_id
      id = null if @newEntry

      data = {
        publication_title: @title
        hidden_id: id
        date:
          year: @year
        publication:
          text: @description
        _wysihtml5_mode: 1
        link: @link
      }
      data
  }

  ProfilePublication = StructFactory.build(props)

  ProfilePublication.prototype = $.extend(
    {},
    ProfileModelPrototype.prototype,
    instanceMethods
  )

  ProfilePublication

ProfilePublicationFactory.$inject = [
  "StructFactory"
  "ProfileModelPrototype"
]

angular.module("meed").factory "ProfilePublicationFactory", ProfilePublicationFactory
