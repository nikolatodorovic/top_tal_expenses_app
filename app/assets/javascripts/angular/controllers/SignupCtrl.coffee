@topTalApp.controller 'SignupCtrl', ['$scope', '$location', '$route', 'Auth', ($scope, $location, $route, Auth) ->

  $scope.signup = (user) ->
    $scope.errors = {}

    signup = Auth.signup(user)

    signup.then ((result) ->
      $location.path '/expenses'
      return
    ), (data) ->
      angular.forEach data.data.errors, (errors, field) ->
        $scope.errorMsg = "You need to enter required data"
        $scope.errors[field] = errors.join(', ')
      $location.path '/signup'
      return
    return

]