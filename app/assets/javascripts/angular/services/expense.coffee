@topTalApp.factory 'Expense', [
  'railsResourceFactory'
  'railsSerializer'
  (railsResourceFactory, railsSerializer) ->
    railsResourceFactory
      url: '/api/expenses'
      name: 'expense'
]
