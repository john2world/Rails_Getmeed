ProfileUserFactory = (StructFactory, ProfileModelPrototype) ->
  # This is a constructor for decorating the User object returned when
  # retrieving a profile
  props = {
    active: Boolean
    alumni: Boolean
    create_dttm: String
    degree: String
    first_name: String
    gender: String
    gpa: String
    handle: String
    headline: String
    image_url: String
    last_login: String
    last_login_dttm: String
    last_name: String
    major: String
    meta_data: Object
    minor: String
    year: String
  }

  init = (o) ->
    o.image_url ||= "http://res.cloudinary.com/resume/image/upload/v1409877319/user_male4-128_q1iypj_lgzk5i.jpg"
    # if data.is_viewer_profile
    o.major_object = {
      major: o.major
      code: o.major_id
    }
    o.major = null
    o.minor_object = {
      major: o.minor
      code: o.minor_id
    }
    o.minor = null

  # Instance fields and methods go here
  instanceMethods = {
    class: () -> ProfileUser
    saveUrl: () -> "/profiles/header/save"
    dataForApi: () ->
      major = minor = null
      if @minor_object && @minor_object.code
        minor = @minor_object.code
      else
        minor = null

      if @major_object && @major_object.code
        major = @major_object.code if @major_object.code
      else
        major = null

      data = {
        first_name: @first_name
        last_name:  @last_name
        email:  @email
        major: major
        minor: minor
        phone_number: @phone_number
        degree: @degree
        gpa: @gpa
        user_year: @year
      }
      data

    getMajor: () ->
      return @major_object.major if @major_object
      @major

    getMinor: () ->
      return @minor_object.major if @minor_object
      @minor

    getName: () ->
      "#{@first_name} #{@last_name}"

  }

  ProfileUser = StructFactory.build(props, init)

  ProfileUser.prototype = $.extend(
    {},
    ProfileModelPrototype.prototype,
    instanceMethods
  )

  ProfileUser

ProfileUserFactory.$inject = [
  "StructFactory"
  "ProfileModelPrototype"
]

angular.module('meed').factory 'ProfileUserFactory', ProfileUserFactory
