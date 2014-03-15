$.noty.defaults.timeout = 2000
$.noty.defaults.layout = 'bottomRight'

angular.module('ghcr', ['ngTable'])
angular.module('ghcr').controller 'SettingsController', ($scope, $filter, $q, ngTableParams) ->
  ghcrConfig = new Config()

  fetchUserData = () ->
    $scope.api.user().then (data) ->
      return false unless data
      $scope.user_data = data
      unless $scope.settings['ghcr_hipchat_username']
        $scope.settings['ghcr_hipchat_username'] = $scope.user_data.hipchat_username
        Storage.set('ghcr_hipchat_username', $scope.user_data.hipchat_username)

      $scope.tableParams = new ngTableParams(
        page: 1 # show first page
        count: 10 # count per page
        sorting:
          pending_count: "desc"
        filter:
          connected: true
      ,
        total: 0 # length of data
        getData: ($defer, params) ->
          # use build-in angular filter
          orderedData  = (if params.sorting then $filter("orderBy")($scope.user_data.repositories, params.orderBy()) else $scope.user_data.repositories)
          orderedData  = (if params.filter then $filter("filter")(orderedData, params.filter()) else orderedData)
          table_data   = orderedData.slice((params.page() - 1) * params.count(), params.page() * params.count())
          params.total(orderedData.length) # set total for recalc pagination
          $defer.resolve(table_data)
      )
      $scope.$apply()

  ghcrConfig.on 'dataChanged', (settings) ->
    $scope.settings = settings
    $scope.api = new API(settings)
    $scope.$apply()

    if $scope.api.initialized()
      fetchUserData()

  ghcrConfig.init()

  $scope.updateSettings = () ->
    ghcrConfig.setData($scope.settings)
    if $scope.api?.initialized() && $scope.settings['ghcr_hipchat_username']
      $scope.api.save_settings({hipchat_username: $scope.settings['ghcr_hipchat_username']})

  $scope.updateConnected = (repo, value) ->
    if $scope.api && value
      repo.connecting = true
      repo.connectingText = 'Working'
      $scope.api.connect(repo.full_name).then(
        ->
          repo.connecting     = false
          repo.connectingText = null
          repo.connected      = true
          $scope.$apply()
          noty(text: "#{repo.full_name}\nconnected successfully to ghcr", type: 'success')
        ,
        ->
          repo.connecting     = false
          repo.connectingText = null
          repo.connected      = false
          $scope.$apply()
          noty(text: 'Cannot connect to GHCR...', type: 'error')
      )
    else
      noty(text: "Cannot disable GHCR (not implemented)", type: 'error')

  $scope.totalPending = ->
    return 0 unless $scope.user_data?
    $scope.user_data.repositories.reduce (prev, curr) ->
      prev + curr.pending_count
    , 0

  $scope.totalDiscuss = ->
    return 0 unless $scope.user_data?
    $scope.user_data.repositories.reduce (prev, curr) ->
      prev + curr.discuss_count
    , 0

  $scope.ghcrFilter = ->
    def = $q.defer()
    def.resolve([{ id: true, title: 'yes' }, { id: false, title: 'no' }])
    def
