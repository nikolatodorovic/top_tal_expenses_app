@topTalApp.controller 'ExpenseCtrl', ['$scope', '$location', '$route', '$routeParams', 'Expense', 'CurrentUser', ($scope, $location, $route, $routeParams, Expense, CurrentUser) ->
  
  $scope.currentUser = CurrentUser
  
  $scope.expenses = []
  $scope.expense = {}
  $scope.errors = {}

  $scope.dateFrom = {}
  $scope.dateTo = {}

  # for table initialization
  $scope.loadExpenses = () ->
    $scope.expenseErrorMsg = ""
    Expense.query().then (results) ->
      $scope.expenses = results

  $scope.edit = (expense) ->
    $location.path('/expense/' + expense.id)

  $scope.loadExpense = () ->
    if $routeParams.id
      $scope.expenseErrorMsg = ""
      Expense.get($routeParams.id).then (expense) ->
        if !expense.id
          $location.path('/expenses')
          return
        $scope.expense = expense
        $scope.expense.forDay = new Date(expense.forTimeday)
        $scope.expense.forTime = new Date(expense.forTimeday).getTime()
    return

  $scope.delete = (expense) ->
    if confirm("Are you sure?")
      expense.delete()
      $scope.loadExpenses()

  $scope.submit = (expense) ->
    $scope.expenseErrorMsg = ""
    $scope.errors = {}
    if _.isEmpty(expense)
      $scope.expenseErrorMsg = "You need to enter some data first"
      return
    if expense.forDay == undefined
      $scope.expenseErrorMsg = "You need to enter date"
      return
    if expense.forTime == undefined
      $scope.expenseErrorMsg = "You need to enter time"
      return
    # if there is an 'id' then it's an update
    if $scope.expense.id
      newTime = new Date(expense.forTime)
      expense.forTimeday = new Date(expense.forDay.getFullYear(), expense.forDay.getMonth(), expense.forDay.getDate(), newTime.getHours(), newTime.getMinutes(), 0)
      expense = new Expense(expense).update()
    # if there isn't an 'id' then it's a new record
    else
      expense.forTimeday = new Date(expense.forDay.getFullYear(), expense.forDay.getMonth(), expense.forDay.getDate(), expense.forTime.getHours(), expense.forTime.getMinutes(), 0)
      expense = new Expense(expense).create()
    expense.then ((data) ->
      $location.path('/expenses')
      $scope.expense = {}
      return
    ), (data) ->
      # error from the API
      angular.forEach data.data, (errors, field) ->
        $scope.expenseErrorMsg = "You need to enter required data"
        $scope.errors[field] = errors.join(', ')
      return
    return

  $scope.reset = ->
    $scope.loadExpenses()
    $scope.expense = {}
    $scope.errors = {}
    $scope.expenseErrorMsg = ""

  $scope.sort = (keyname) ->
    $scope.sortKey = keyname
    $scope.reverse = !$scope.reverse


  # Filters

  $scope.filterDateTimeReset = ->
    $scope.filterDate = null
    $scope.filterTime = null
    $scope.loadExpenses()


  $scope.badTime = (dateFrom, dateTo, timeFrom, timeTo) ->
    if dateFrom != undefined and dateTo != undefined and timeFrom != undefined and timeTo != undefined and dateFrom.getTime() == dateTo.getTime() and timeFrom > timeTo
      return true
    return false

  $scope.filterDateTime = ->
    $scope.dateTo = {}
    $scope.dateFrom = {}
    if $scope.filterDate and $scope.filterDate.from
      if $scope.filterTime and $scope.filterTime.from
        dateFrom = new Date($scope.filterDate.from.getFullYear(), $scope.filterDate.from.getMonth(), $scope.filterDate.from.getDate(), $scope.filterTime.from.getHours(), $scope.filterTime.from.getMinutes(), 0)
      else
        dateFrom = new Date($scope.filterDate.from.getFullYear(), $scope.filterDate.from.getMonth(), $scope.filterDate.from.getDate(), 0, 0, 0)

    if $scope.filterDate and $scope.filterDate.to
      if $scope.filterTime and $scope.filterTime.to
        dateTo = new Date($scope.filterDate.to.getFullYear(), $scope.filterDate.to.getMonth(), $scope.filterDate.to.getDate(), $scope.filterTime.to.getHours(), $scope.filterTime.to.getMinutes(), 0)
      else
        dateTo = new Date($scope.filterDate.to.getFullYear(), $scope.filterDate.to.getMonth(), $scope.filterDate.to.getDate(), 23, 59, 59)

    if dateFrom and dateTo == undefined
      $scope.dateFrom = dateFrom
      Expense.query({datefrom: dateFrom}).then (results) ->
        $scope.expenses = results

    if dateTo and dateFrom == undefined
      $scope.dateTo = dateTo
      Expense.query({dateto: dateTo}).then (results) ->
        $scope.expenses = results

    if dateFrom and dateTo
      $scope.dateFrom = dateFrom
      $scope.dateTo = dateTo
      Expense.query({datefrom: dateFrom, dateto: dateTo}).then (results) ->
        $scope.expenses = results


  $scope.generateReport = ->
    search = {}
    unless angular.equals({}, $scope.dateFrom)
      search.datefrom = $scope.dateFrom
    unless angular.equals({}, $scope.dateTo)
      search.dateto = $scope.dateTo
    # I need to know the difference from the UTC time and the local time
    search.timezone = (new Date()).getTimezoneOffset()
    $location.search(search).path('/expenses/weekly')

  # Datepickers and timepickers

  $scope.openDatepickerForDay = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mydpForDay) == 'undefined')
      $scope.mydpForDay = {}
    $scope.mydpForDay.opened = true

  $scope.openTimepickerForTime = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mytpForTime) == 'undefined')
      $scope.mytpForTime = {}
    $scope.mytpForTime.opened = true

  $scope.openDatepickerFilterFrom = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mydpFilterFrom) == 'undefined')
       $scope.mydpFilterFrom = {}
    $scope.mydpFilterFrom.opened = true

  $scope.openDatepickerFilterTo = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mydpFilterTo) == 'undefined')
       $scope.mydpFilterTo = {}
    $scope.mydpFilterTo.opened = true

  $scope.openTimepickerFilterFrom = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mytpFilterFrom) == 'undefined')
       $scope.mytpFilterFrom = {}
    $scope.mytpFilterFrom.opened = true

  $scope.openTimepickerFilterTo = ($event) ->
    $event.preventDefault()
    $event.stopPropagation()
    if (typeof($scope.mytpFilterTo) == 'undefined')
       $scope.mytpFilterTo = {}
    $scope.mytpFilterTo.opened = true

]