@topTalApp.factory 'User', [
  'railsResourceFactory'
  (railsResourceFactory) ->
    railsResourceFactory
      url: '/api/users'
      name: 'user'
]
