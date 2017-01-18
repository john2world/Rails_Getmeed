ProfileFactory = (MeedApiFactory, CurrentUserFactory) ->

  updateCurrentCompany = (data, success = false) ->
    url = "/profiles/current_company/save"
    return MeedApiFactory.post( url: url, data: data, success: success )

  updatePreviousCompany = (data, success = false) ->
    url = "/profiles/previous_company/save"
    return MeedApiFactory.post( url: url, data: data, success: success )

  followUser = (handle, source='') ->
    url = "/#{handle}/follow?source=#{source}"
    MeedApiFactory.post(url)

  inviteLead = (id, source='') ->
    url = "/#{id}/invite?source=#{source}"
    MeedApiFactory.post(url)

  getUserRecommendations = () ->
    url = "/user/recommendations"
    return MeedApiFactory.get(url)

  getLeadUserRecommendations = () ->
    url = "/user/lead/recommendations"
    return MeedApiFactory.get(url)


  unfollowUser = (handle, source="") ->
    url = "/#{handle}/unfollow?source=#{source}"
    MeedApiFactory.post(url)

  getProfile = (handle, with_contact_info) ->
    url = "/#{handle}"
    if with_contact_info
      url = "#{url}?showRajni=true"
    return MeedApiFactory.get(url)

  updateBio = (data, success = false) ->
    url = "/profiles/bio/save"
    MeedApiFactory.post( url: url, data: data, success: success )

  updateObjective = (data, success = false) ->
    url = "/profiles/objective/save"
    MeedApiFactory.post( url: url, data: data, success: success )

  updateHeadline = (data, success = false) ->
    url = "/profiles/headline/save"
    MeedApiFactory.post( url: url, data: data, success: success )

  updateProfileImage = (data, success = false) ->
    url = "/profiles/photo/save"
    MeedApiFactory.post( url: url, data: data, success: success )

  uploadResumeFile = (data, success = false) ->
    url = "/resume/upload/"
    MeedApiFactory.post( url: url, data: data, success: success )

  return {
  getProfile:      getProfile
  updateObjective: updateObjective
  updateHeadline:  updateHeadline
  updateBio: updateBio
  followUser: followUser
  unfollowUser: unfollowUser
  updateProfileImage: updateProfileImage
  updateCurrentCompany: updateCurrentCompany
  updatePreviousCompany: updatePreviousCompany
  getUserRecommendations: getUserRecommendations
  getLeadUserRecommendations: getLeadUserRecommendations
  inviteLead: inviteLead
  uploadResumeFile: uploadResumeFile
  }

ProfileFactory.$inject = [
  "MeedApiFactory"
  "CurrentUserFactory"
]

angular.module("meed").factory "ProfileFactory", ProfileFactory
