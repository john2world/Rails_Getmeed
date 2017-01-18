ProfileEducationFactory = (StructFactory, ProfileModelPrototype) ->

  # Properties to expect coming in from the API
  props = {
    _id: String
    degree: String
    end_year: String
    handle: String
    kudos_count: String
    major: String
    minor: String
    name: String
    start_year: String
  }

  # Instance fields and methods go here
  instanceMethods = {
    class: () -> ProfileEducation
    saveUrl: () -> "/profiles/education/save"
    dataForApi: () ->
      id = @_id
      id = null if @newEntry

      data = {
        education_name: @name
        hidden_id: id
        date: {
          start_year: @start_year
          end_year: @end_year
        }
        education_degree: @degree
        education_majors: @major
      }
      data
  }

  ProfileEducation = StructFactory.build(props)

  ProfileEducation.prototype = $.extend(
    {},
    ProfileModelPrototype.prototype,
    instanceMethods
  )

  ProfileEducation


ProfileEducationFactory.$inject = [
  "StructFactory"
  "ProfileModelPrototype"
]

angular.module('meed').factory 'ProfileEducationFactory', ProfileEducationFactory
