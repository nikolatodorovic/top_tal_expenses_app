@topTalApp = angular.module('topTalApp', ['ngRoute', 'rails', 'templates', 'ui.bootstrap', 'sy.bootstrap.timepicker', 'angularUtils.directives.dirPagination'])

@topTalApp

  # authorization part - if an unauthorized user tries to reach a rout she doesn't have the permission, than she has to be redirected to another route
  .run [
    '$rootScope'
    '$location'
    'Auth'
    ($rootScope, $location, Auth) ->
      $rootScope.$on '$routeChangeStart', (event, next, current) ->
        if next.access != undefined and !Auth.isAuthorized(next.access.requiredPermissionsAnyOf)
          # had to do this since a manager user doesn't have the permission to go to the default page
          if next.templateUrl == 'expenses/expenses.html' and Auth.isAuthenticated() != null
            $location.path '/users'
          else if next.templateUrl == 'expenses/expenses.html' and Auth.isAuthenticated() == null
            $location.path '/login'
          else
            $location.path '/'
        return
      return
  ]

  .config [
    '$httpProvider'
    ($httpProvider) ->
      # I enabled CSRF protection in rails. Rails will set a cookie named XSRF-TOKEN on the first GET request and expects a custom HTTP header X-XSRF-TOKEN on later POST/PUT/DELETE requests.

      # For Angular, it expects the cookie named XSRF-TOKEN and will do POST/PUT/DELETE requests with X-XSRF-TOKEN header, so I need to set it like this

      # Like any other technology, AngularJS is not impervious to attack. Angular does, however, provide built-in protection from basic security holes, including cross-site scripting and HTML injection attacks. AngularJS does round-trip escaping on all strings and even offers XSRF protection for server-side communication.
      
      $httpProvider.defaults.xsrfCookieName = 'XSRF-TOKEN'
      $httpProvider.defaults.xsrfHeaderName = 'X-XSRF-TOKEN'

      return
  ]


  .config(

    ($routeProvider) ->
    
      $routeProvider
        .when '/signup', {templateUrl: 'sessions/signup.html', controller: 'SignupCtrl'}
        .when '/login', {templateUrl: 'sessions/login.html', controller: 'LoginCtrl'}

        .when '/', {
          templateUrl: 'expenses/expenses.html',
          controller: 'ExpenseCtrl',
          access: requiredPermissionsAnyOf: [ 'REGULAR', 'ADMIN' ]
        }


        .when '/expenses', {
          templateUrl: 'expenses/expenses.html',
          controller: 'ExpenseCtrl',
          access: requiredPermissionsAnyOf: [ 'REGULAR', 'ADMIN' ]
        }

        .when '/new_expense', {
          templateUrl: 'expenses/new_edit_expense.html',
          controller: 'ExpenseCtrl',
          access: requiredPermissionsAnyOf: [ 'REGULAR', 'ADMIN' ]
        }

        .when '/expense/:id', {
          templateUrl: 'expenses/new_edit_expense.html',
          controller: 'ExpenseCtrl',
          access: requiredPermissionsAnyOf: [ 'REGULAR', 'ADMIN' ]
        }

        .when '/expenses/weekly', {
          templateUrl: 'expenses/weekly.html',
          controller: 'ExpenseWeeklyCtrl',
          access: requiredPermissionsAnyOf: [ 'REGULAR', 'ADMIN' ]
        }

        .when '/users', {
          templateUrl: 'users/users.html',
          controller: 'UserCtrl',
          access: requiredPermissionsAnyOf: [ 'MANAGER', 'ADMIN' ]
        }

        .when '/new_user', {
          templateUrl: 'users/new_edit_user.html',
          controller: 'UserCtrl',
          access: requiredPermissionsAnyOf: [ 'MANAGER', 'ADMIN' ]
        }

        .when '/user/:id', {
          templateUrl: 'users/new_edit_user.html',
          controller: 'UserCtrl',
          access: requiredPermissionsAnyOf: [ 'MANAGER', 'ADMIN' ]
        }

        .otherwise({redirectTo: '/'})

  )