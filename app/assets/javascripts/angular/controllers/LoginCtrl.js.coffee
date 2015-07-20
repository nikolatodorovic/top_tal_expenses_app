@topTalApp.controller 'LoginCtrl', ['$scope', '$location', 'Auth', ($scope, $location, Auth) ->

  $scope.expenses = []

  $scope.login = (user) ->

    login = Auth.login(user)

    login.then ((result) ->
      $location.path '/expenses'
      return
    ), (error) ->
      return

    return

]