# filter to show time from timedate column
@topTalApp.filter 'timeFilter', ($filter) ->
  (input) ->
    if input == null
      return ''
    _time = $filter('date')(new Date(input), 'HH:mm:ss')
