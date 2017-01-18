ProfileCourseProjectFactory = (StructFactory, ProfileModelPrototype) ->

  props = {
    _id: String
    course_review_id: String
    description: String
    handle: String
    kudos_count: Number
    link: String
    semester: String
    skills: Array
    start_date: String
    title: String
    year: String
    reviews: Array
  }

  instanceMethods = {
    class: () -> ProfileCourseProject
    saveUrl: () -> "/profiles/course/save"
    dataForApi: () ->
      id = @_id
      id = null if @newEntry

      data = {
        course_title: @title
        hidden_id: id
        semester: @semester
        date:
          year: @year
        course_description:
          text: @description
        _wysihtml5_mode: 1
        course_skills: @skills
        course_reviews: @reviews
        link: @link
      }
      data
  }

  ProfileCourseProject = StructFactory.build(props)

  ProfileCourseProject.prototype = $.extend(
    {},
    ProfileModelPrototype.prototype,
    instanceMethods
  )

  ProfileCourseProject

ProfileCourseProjectFactory.$inject = [
  "StructFactory"
  "ProfileModelPrototype"
]

angular.module('meed').factory 'ProfileCourseProjectFactory', ProfileCourseProjectFactory
