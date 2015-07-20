@topTalApp.controller 'ExpenseWeeklyCtrl', ['$scope', '$location', 'Expense', ($scope, $location, Expense) ->

  url = $location.search()

  Expense.$get('/api/expenses/weekly', url).then (data) ->
    $scope.expenses = data
    return

]