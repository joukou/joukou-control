###*
Copyright 2014 Joukou Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###
EdgeController = ($scope, Hyperagent, $log, $stateParams, env, $http) ->
  $scope.getCreateConnectionLink = ->
    graphResponseLinks = $scope.graphData.links
    graphResponseLinks['joukou:connection-create'][0]
  $scope.getDeleteConnectionLink = ->
    graphResponseLinks = $scope.graphData.links
    graphResponseLinks['joukou:connection-delete'][0]
  $scope.getConnectionPostData = (connectionData) ->
    postData =
      '_links':
        'joukou:process': [
          {
            href: connectionData.from.node
            name: 'src'
            port: connectionData.from.port
          },
          {
            href: connectionData.to.node
            name: 'tgt'
            port: connectionData.to.port
          }
        ]
    JSON.stringify(postData)
  $scope.addConnection = (connectionData) ->
    if $scope.isClonedProcessID(connectionData.from.node)
      return
    if $scope.isClonedProcessID(connectionData.to.node)
      return
    createConnectionLink = $scope.getCreateConnectionLink()
    postData = $scope.getConnectionPostData(connectionData)
    onSave = (connection) ->
      router = new routes()
      router.addRoute('/persona/:personaKey/graph/:graphKey/connection/:connectionKey', -> )
      link = connection.links["joukou:connection"][0].href
      match = router.match(link)
      if not match
        return
      connectionData.metadata.key = match.params.connectionKey
      $log.debug( "connection created ", connectionData, connection )
    createConnectionLink.fetch({
      ajax: {
        type: 'POST'
        data: postData
      }
    })
    .then(onSave)
    .catch( (error) ->
      $log.warn( "Error fetching API ", error )
    )
  $scope.removeConnection = (connectionData) ->
    if $scope.isCloned(connectionData.src)
      return
    if $scope.isCloned(connectionData.tgt)
      return
    remove = new Hyperagent.Resource("#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph/#{$stateParams.graph}/connection/#{connectionData.metadata.key}")
    postData = $scope.getConnectionPostData(connectionData)
    remove.del(postData)
    .then( ->
      $log.debug( "connection deleted ", connectionData )
    )
    .catch( (error) ->
      $log.warn( "Error fetching API ", error )
    )

EdgeController.$inject = [ '$scope', 'Hyperagent', '$log', '$stateParams', 'env',  ]

angular.module('ngJoukou.grapheditor')
.controller('EdgeController', EdgeController)