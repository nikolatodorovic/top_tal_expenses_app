@topTalApp.controller 'UserCtrl', ['$scope', '$location', '$route', '$routeParams', 'User', ($scope, $location, $route, $routeParams, User) ->
  
  $scope.users = []
  $scope.user = {}
  $scope.errors = {}

  # for table initialization
  $scope.loadUsers = () ->
    $scope.userErrorMsg = ""
    User.query().then (results) ->
      $scope.users = results

  $scope.edit = (user) ->
    $location.path('/user/' + user.id)

  $scope.loadUser = () ->
    if $routeParams.id
      $scope.userErrorMsg = ""
      User.get($routeParams.id).then (user) ->
        if !user.id
          $location.path('/users')
          return
        $scope.user = user
    return

  $scope.delete = (user) ->
    if confirm("Are you sure?")
      user.delete()
      $scope.loadUsers()

  $scope.submit = (user) ->
    $scope.userErrorMsg = ""
    $scope.errors = {}
    if _.isEmpty(user)
      $scope.userErrorMsg = "You need to enter some data first"
      return
    # if there is an 'id' then it's an update
    if $scope.user.id
      user = new User(user).update()
    # if there isn't an 'id' then it's a new record
    else
      user = new User(user).create()
    user.then ((data) ->
      $location.path('/users')
      $scope.user = {}
      return
    ), (data) ->
      # error from the API
      angular.forEach data.data, (errors, field) ->
        $scope.userErrorMsg = "You need to enter required data"
        $scope.errors[field] = errors.join(', ')
      return
    return

]