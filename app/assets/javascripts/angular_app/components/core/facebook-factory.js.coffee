FacebookFactory = ($facebook,
                   UTILS,
                   MeedApiFactory) ->
  friends = new Array()
  friends_url = '/me/taggable_friends'
  friends_save_url = '/facebook/friends/save'
  me_url = '/me?fields=id,first_name,last_name,picture,email'

  getUserInformation = () ->
    $facebook.login().then(->
      $facebook.api(me_url).then ((response) ->
        if response
          user = {}
          user['first_name']= response.first_name
          user['last_name']= response.last_name
          user['email']= response.email
          if response.picture
            user['picture'] = response.picture.data.url
          return user
      ), (err) ->
        if err.type == 'OAuthException'
          console.log(err)
    )

  getFacebookFriends = (url, friends) ->
    $facebook.api(url).then ((response) ->
      if response.data
        for frObj in response.data
          friend = {}
          friend['name'] = frObj.name
          friend['picture'] = frObj.picture.data.url
          friends.push(friend)

        if response.paging.next
          return getFacebookFriends(response.paging.next, friends)
        else
          return true

    ), (err) ->
      if err.type == 'OAuthException'
        return $facebook.login().then(->
          getFacebookFriends
        )
      return


  saveFacebookFriends = (redirect_url) ->
    myDataPromise = getFacebookFriends(friends_url, friends)
    myDataPromise.then (result) ->
      mySecondPromise = MeedApiFactory.post(url: friends_save_url, data: {friends: friends} )
      mySecondPromise.then (result) ->
        UTILS.redirect(redirect_url)
        return

  return {
  saveFacebookFriends:  saveFacebookFriends
  getFacebookFriends: getFacebookFriends
  getUserInformation: getUserInformation

  }

FacebookFactory.$inject = [
  "$facebook"
  "UTILS"
  "MeedApiFactory"
]

angular.module("meed").factory "FacebookFactory", FacebookFactory
