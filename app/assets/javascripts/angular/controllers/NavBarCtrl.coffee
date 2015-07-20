@topTalApp.controller 'NavBarCtrl', ['$scope', 'Auth', 'CurrentUser', ($scope, Auth, CurrentUser) ->
  $scope.auth = Auth
  $scope.currentUser = CurrentUser

  $scope.logout = ->
    Auth.logout()
    return

  return

]
