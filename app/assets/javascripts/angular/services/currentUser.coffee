@topTalApp.factory 'CurrentUser', ['ROLES', (ROLES) ->
  
  {
    user: ->
      if localStorage.getItem('auth_token')
        angular.fromJson(localStorage.getItem('auth_token')).user
      else
        {}

    getRole: ->
      if localStorage.getItem('auth_token')
        angular.fromJson(localStorage.getItem('auth_token')).user.id_role
      else
        0
  }

]