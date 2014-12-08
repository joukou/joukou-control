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
PortController = ( $scope, env, $stateParams, $resource ) ->
  Inport = $resource("#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph/#{$stateParams.graph}/inport")
  Outport = $resource("#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph/#{$stateParams.graph}/outport")

  $scope.addOutport = (details) ->
    outport = new Outport(details)
    outport.$save()
  $scope.addInport = (details) ->
    inport = new Inport(details)
    inport.$save()

  $scope.removeOutport = (details) ->
    outport = new Outport(details)
    outport.$remove()
  $scope.removeInport = (details) ->
    inport = new Inport(details)
    inport.$remove()

PortController.$inject = [ '$scope', 'env', '$stateParams', '$resource' ]
angular.module('ngJoukou.grapheditor')
.controller('PortController', PortController)