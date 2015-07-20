@topTalApp.factory('AuthInterceptor', ($location, $rootScope, $q, $injector) ->
  
  authInterceptor = {

    request: (config) ->
      token = undefined
      if localStorage.getItem('auth_token')
        token = angular.fromJson(localStorage.getItem('auth_token')).token
      if token
        config.headers.Authorization = 'Bearer ' + token
      config

    responseError: (response) ->
      if response.status == 401
        # unauthenticated, needs to login first
        localStorage.removeItem 'auth_token'
        $rootScope.errorMsg = response.data.error
        $location.path '/login'
      if response.status == 403
        # unauthorized, redirect user to the index page
        $rootScope.errorMsg = response.data.error
        $location.path '/'
      $q.reject response

  }
  
  authInterceptor

).config ($httpProvider) ->
  $httpProvider.interceptors.push 'AuthInterceptor'
  return
