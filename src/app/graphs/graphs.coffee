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

This is the module for the graphs page.
###

GraphsCtrl = ( $scope, $log, env, $location, Hyperagent, $stateParams ) ->
  $scope.graphsLoaded = false
  $scope.newGraph = {
    name: ''
  }
  $scope.graphs = []
  $scope.loadGraphs = ->
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph" ).fetch().then( ( response ) ->
      $log.debug('joukou api get persona graphs response',response)
      $scope.graphsLoaded = true
      $scope.graphs = response.embedded['joukou:graph']
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.getCreateGraphPostData = ->
    JSON.stringify({
      name: $scope.newGraph.name
    })
  $scope.createGraph = ->
    return if $scope.newGraph.name is "" or $scope.graphsLoaded is false
    postData = $scope.getCreateGraphPostData()
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph" ).fetch({
      ajax: {
        type: 'POST'
        data: postData
      }
    }).then( ( response ) ->
      $log.debug('joukou api create graph',response)
      setTimeout( ->
        $scope.loadGraphs()
      , 1000)
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.getGraph = (graph) ->
    graph.links.self.fetch().then( (graph) ->
      $log.debug('getGraph result',graph)
      $scope.navigateToGraphEditor(graph)
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.onGraphSelected = (graph) ->
    $log.debug('onGraphSelected',graph.props)
    $scope.navigateToGraphEditor(graph)
  $scope.navigateToGraphEditor = (graph) ->
    $location.path( "/grapheditor/#{$stateParams.persona}/#{graph.props.key}" ).replace()
  $scope.loadGraphs()

GraphsCtrl.$inject = ['$scope', '$log', 'env', '$location', 'Hyperagent', '$stateParams']

Config = ( $stateProvider ) ->
  $stateProvider.state( 'graphs',
    url: '/graphs/:persona'
    views:
      main:
        controller: 'GraphsCtrl'
        templateUrl: 'app/graphs/graphs.html'
    data:
      pageTitle: 'Graphs'
  )

Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.graphs', [
  'ui.router'
  'ngJoukou.env'
  'ngJoukou.api'
] )
.config(Config)
.controller( 'GraphsCtrl', GraphsCtrl)
