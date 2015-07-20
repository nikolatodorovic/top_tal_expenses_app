@topTalApp.factory 'Auth', ['$http', 'CurrentUser', 'ROLES', ($http, CurrentUser, ROLES) ->

  currentUser = CurrentUser

  token = localStorage.getItem('auth_token')

  checkTokenStatus = (token) ->
    $http.get '/auth/token_status?token=' + token
    return

  if token
    token = angular.fromJson(localStorage.getItem('auth_token')).token
    checkTokenStatus token

  {
    isAuthenticated: ->
      localStorage.getItem 'auth_token'

    login: (user) ->
      login = $http.post('/auth/authenticate', user)
      login.success (result) ->
        localStorage.setItem 'auth_token', JSON.stringify(result)
        return
      login

    logout: ->
      localStorage.removeItem 'auth_token'
      return

    signup: (user) ->
      localStorage.removeItem 'auth_token'
      register = $http.post('/auth/register', user)
      register.success (result) ->
        localStorage.setItem 'auth_token', JSON.stringify(result)
        return
      register

    isRegularUser: (user) ->
      user.getRole() == ROLES.REGULAR

    isAdminUser: (user) ->
      user.getRole() == ROLES.ADMIN

    isManagerUser: (user) ->
      user.getRole() == ROLES.MANAGER

    isAuthorized: (permissions) ->
      i = 0
      while i < permissions.length
        switch permissions[i]
          when 'REGULAR'
            return true if currentUser.getRole() == ROLES.REGULAR
          when 'ADMIN'
            return true if currentUser.getRole() == ROLES.ADMIN
          when 'MANAGER'
            return true if currentUser.getRole() == ROLES.MANAGER
        i += 1
      return false

  }

]