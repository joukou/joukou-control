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
StateController = ($scope, $log) ->
  $scope.getState = ->
    $scope.editor.getState()
  $scope.setState = (scale, x, y) ->
    element = angular.element(
      "#joukouGraphEditor"
    )[0]
    if not element
      return
    element.setState(scale, x, y)
  $scope.setStateEmbedded = ->
    embedded = $scope.graphData.embedded
    state = embedded["joukou:graph:state"]
    if not state or not state.props
      return
    props = state.props
    $scope.setState(props.scale, props.x, props.y)
    metadata = props.metadata or {}
    $scope.state.leftMenu = !!metadata.leftMenu
    $scope.state.running = !!metadata.running

  $scope.getUpdateStateLink = ->
    graphResponseLinks = $scope.graphData.links
    graphResponseLinks['joukou:graph:state'][0]

  $scope.saveState = ->
    $scope.stateChanged(
      $scope.getState()
    )

  $scope.stateChanged = (detail) ->
    link = $scope.getUpdateStateLink()
    data = {
      x: detail.x
      y: detail.y
      scale: detail.scale
      metadata: {
        leftMenu: $scope.state.leftMenu
      # TODO Change running state to persona and integrate with conductor
        running: $scope.state.running
      }
    }
    link.fetch({
      ajax: {
        type: "PUT"
        data: JSON.stringify(data)
      }
    }).then( ->
      $log.debug( "Updated state ", data)
    ).catch( (error) ->
      console.warn("Error fetching API", error)
      console.warn("Error fetching API", error)
    )

StateController.$inject = [ '$scope', '$log' ]
angular.module('ngJoukou.grapheditor')
.controller('StateController', StateController)