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
GraphEditorController = ($scope, env, $log, $stateParams, Hyperagent, $window, $controller, $http) ->
  $scope.circles = []
  $scope.graphData = {}
  $scope.libraryData = {}
  $scope.processMap = {}
  $scope.defaultCircleX = 310
  $scope.defaultCircleY = 100
  $scope.showLeftMenu = true
  $scope.circleSearchTerm = ""
  $scope.circleSearchLoading = no

  $scope.state = {
    running: false
    leftMenu: true
  }
  $scope.editor = angular.element(
    "#joukouGraphEditor"
  )[0]

  $controller('ComponentController', '$scope': $scope)
  $controller('EdgeController', '$scope': $scope)
  $controller('StateController', '$scope': $scope)
  $controller('ProcessController', '$scope': $scope)
  $controller('PortController', '$scope': $scope)

  $scope.getGraph = ->
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph/#{$stateParams.graph}" ).fetch().then( ( response ) ->
      for key of response.props.processes
        if not response.props.processes.hasOwnProperty(key)
          continue
        circle = response.props.processes[key].metadata.circle
        $scope.libraryData[circle.key] = circle.value
      $scope.updateComponents()
      $scope.graphData = response
      $scope.setStateEmbedded()
      #$scope.$apply()
      $scope.loadCircles()
    ).catch( (error) ->
      console.warn("Error fetching API", error)
    )

  $scope.windowElement = angular.element($window)
  $scope.width = 500
  $scope.height = 500
  $scope.onResize = ->
    element = angular.element("#joukouGraphEditor")
    element.width($scope.windowElement.innerWidth())
    element.height($scope.windowElement.innerHeight() - 55)

  # TODO once API side is complete
  $scope.startGraph = ->
    $scope.state.running = true
    $scope.saveState()
  $scope.stopGraph = ->
    $scope.state.running = false
    $scope.saveState()


  $scope.openLeftMenu = ->
    $scope.state.leftMenu = true
    $scope.saveState()
  $scope.closeLeftMenu = ->
    $scope.state.leftMenu = false
    $scope.saveState()

  angular.element(
    $scope.editor
  ).on("nodeMoved", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    if not detail.key or detail.x is undefined or detail.y is undefined
      return
    $scope.moveProcess(detail)
  ).on("addConnection", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.addConnection(detail)
  ).on("removeConnection", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.removeConnection(detail)
  ).on("stateChanged", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.stateChanged(detail)
  ).on("nodeRemoved", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.removeProcess(detail)
  ).on("paste", (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.clone(detail)
  ).on('addOutport', (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.addOutport(detail)
  ).on('addInport', (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.addInport(detail)
  ).on('removeOutport', (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.removeOutport(detail)
  ).on('removeInport', (event) ->
    event = event.originalEvent or event
    detail = event.detail
    $scope.removeInport(detail)
  )

  angular.element($window).bind('resize', ->
    $scope.onResize()
  )

  $scope.onResize()

  $scope.getGraph()


GraphEditorController.$inject = [ '$scope', 'env', '$log', '$stateParams', 'Hyperagent', '$window', '$controller', '$http' ]

Config = ( $stateProvider ) ->
  $stateProvider.state( 'grapheditor',
    url: '/grapheditor/:persona/:graph'
    views:
      main:
        controller: 'GraphEditorCtrl'
        templateUrl: 'app/grapheditor/grapheditor.html'
    data:
      pageTitle: 'Graph Editor'
    #hideHeader: true
      hideFooter: true
  )
Config.$inject = ['$stateProvider']
###*
This is the module for the graph editor page.
###
angular.module( 'ngJoukou.grapheditor', [
  'ui.router'
  'ngJoukou.env'
] )
.config(Config)
.controller( 'GraphEditorCtrl', GraphEditorController)
