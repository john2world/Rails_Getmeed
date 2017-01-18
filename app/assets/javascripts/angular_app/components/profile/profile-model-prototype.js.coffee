# Just a mixin for the common functions we want to have in our "models"
# used for viewing and editing in the profile
# Each class that extends this base will have to define:
#  @class: returns the class of the object
#  @saveUrl: returns the API endpoint for saving changes
#  @dataForApi: returns a JSON object properly formatted for sending to the API

ProfileModelPrototype = (MeedApiFactory) ->
  prototype =  {
    _showEdit: false
    _backup: {}

    showEdit: () -> @_showEdit

    openEdit: () -> @_showEdit = true

    closeEdit: () -> @_showEdit = false

    backup: () ->
      @_backup = {}
      for name of @class().meta.props
        @_backup[name] = @[name]
      @_backup

    restoreBackup: () ->
      for name of @_backup
        @[name] = @_backup[name]

    del: (success = false) ->
      data = {
        hidden_id: @_id
        "delete": true
      }

      url = @saveUrl()
      MeedApiFactory.post( url: url, data: data, success: success )

    save: (success = false) ->
      # Clean data before we send it to the server
      data = @dataForApi()
      url = @saveUrl()
      MeedApiFactory.post( url: url, data: data, success: success )
  }
  return {
    prototype: prototype
  }

ProfileModelPrototype.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "ProfileModelPrototype", ProfileModelPrototype
