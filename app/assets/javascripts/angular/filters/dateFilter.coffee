# filter to show date from timedate column
@topTalApp.filter 'dateFilter', ($filter) ->
  (input) ->
    if input == null
      return ''
    _date = $filter('date')(new Date(input), 'yyyy-MM-dd')
