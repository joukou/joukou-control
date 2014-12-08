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

This is the module for the persona page.
###
PersonaCtrl = ( $location, $scope, $log, env, Hyperagent, $timeout ) ->
  $scope.personasLoaded = false
  $scope.newPersona = {
    name: ''
  }
  $scope.personas = []
  $scope.loadPersonas = ->
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona" ).fetch(
      force: true
    ).then( ( response ) ->
      $log.debug('joukou api get comnponents response',response)
      $scope.personasLoaded = true
      $scope.personas = response.embedded['joukou:persona']
      console.log($scope.personas)
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.getCreatePersonPostData = ->
    JSON.stringify({
      name: $scope.newPersona.name
    })
  $scope.createPersona = ->
    return if $scope.newPersona.name is "" or $scope.personasLoaded is false
    postData = $scope.getCreatePersonPostData()
    new Hyperagent.Resource( "#{env.getApiBaseUrl()}/persona" ).fetch({
      ajax: {
        type: 'POST'
        data: postData
      },
      force: false
    }).then( ( response ) ->
      $log.debug('joukou api create persona',response)
      $timeout( ->
        $scope.loadPersonas()
      , 1000)
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.getPersona = (persona) ->
    persona.links.self.fetch().then( (persona) ->
      $scope.navigateToGraph(persona)
    ).catch( (error) ->
      $log.error("Error fetching API", error)
    )
  $scope.onPersonaSelected = (persona) ->
    $log.debug('onPersonaSelected', persona.props)
    $scope.navigateToGraph(persona)
  $scope.navigateToGraph = (persona) ->
    $location.path( "/graphs/#{persona.props.key}").replace()
  $scope.loadPersonas()

PersonaCtrl.$inject = ['$location', '$scope', '$log', 'env', 'Hyperagent', '$timeout']

Config = ( $stateProvider ) ->
  $stateProvider.state( 'persona',
    url: '/persona'
    views:
      main:
        controller: 'PersonaCtrl'
        templateUrl: 'app/persona/persona.html'
    data:
      pageTitle: 'Persona'
  )

Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.persona', [
  'ui.router'
  'ngJoukou.env'
  'ngJoukou.api'
] )
.config(Config)
.controller( 'PersonaCtrl', PersonaCtrl)
