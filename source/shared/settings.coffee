$.noty.defaults.timeout = 2000
$.noty.defaults.layout = 'bottomRight'

@SettingsController = ($scope, $http) ->
  $scope.user = User

  return unless User.api

  User.api.user().then (data) ->
    $scope.user_data = data
    $scope.$apply()

  $scope.updateConnected = (repo, value) ->
    if value
      User.api.connect(repo).then(
        -> noty(text: "#{repo}\nconnected successfully to ghcr", type: 'success')
        -> noty(text: 'Cannot connect to GHCR...', type: 'error')
      )
    else
      noty(text: "Cannot disable GHCR (not implemented)", type: 'error')

  $scope.totalPending = ->
    return 0 unless $scope.user_data?
    $scope.user_data.repositories.reduce (prev, curr) ->
      prev + curr.pending_count
    , 0

  $scope.totalRejected = ->
    return 0 unless $scope.user_data?
    $scope.user_data.repositories.reduce (prev, curr) ->
      prev + curr.rejected_count
    , 0
