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
ComponentController = ($scope, env, $stateParams) ->
  $scope.getDefaultCirclePosition = ->
    state = $scope.getState()
    return {
    x: $scope.defaultCircleX - state.x
    y: $scope.defaultCircleY - state.y
    }
  $scope.addCircleToGraphLibrary = (circle) ->
    $scope.editor.addNewComponent(circle.props)
  $scope.onCircleSelected = (circle) ->
    createProcessLink  = $scope.getCreateProcessLink()
    postData = $scope.getCreateProcessPostData(circle)
    createProcessLink.fetch({
      ajax: {
        type: 'POST'
        data: postData
      }
    }).then( (process) ->
      $scope.addCircleToGraphLibrary(circle)
      $scope.addProcessToGraph(circle,process)
      $scope.addProcessToEmbedded(process)
      #$scope.$apply()
    ).catch( (error) ->
      console.warn("Error fetching API", error)
    )
  $scope.updateComponents = ->
    $scope.editor.addComponentsToLibrary(
      $scope.libraryData
    )
  $scope.loadCircles = ->
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/circle" ).fetch().then( ( response ) ->
      $scope.circles = response.embedded['joukou:circle']

      console.log($scope.circles)
      #$scope.$apply()
    ).catch( (error) ->
      console.warn("Error fetching API", error)
    )

  $scope.circleSearchChange = ->
    if not $scope.circleSearchTerm.trim()
      $scope.circles = $scope.originalCircles or $scope.circles or []
      $scope.originalCircles = undefined
      return
    $scope.circleSearchLoading = yes
    new Hyperagent.Resource("#{env.getApiBaseUrl()}/circle/search/#{$scope.circleSearchTerm}")
    .fetch()
    .then((response) ->
      $scope.circleSearchLoading = no
      $scope.originalCircles = $scope.originalCircles or $scope.circles
      $scope.circles = response.embedded["joukou:circle"]
      console.log($scope.circles)
    )
    .catch(->
      $scope.circleSearchLoading = no
    )

ComponentController.$inject = [ '$scope', 'env', '$stateParams' ]
angular.module('ngJoukou.grapheditor')
.controller('ComponentController', ComponentController)