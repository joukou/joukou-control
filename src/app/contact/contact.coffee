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
ContactCtrl = ( $scope, $http, ContactResource, $location, AnchorSmoothScroll ) ->
  $scope.scrollTo = (hash) ->
    $location.hash(hash)
    AnchorSmoothScroll.scrollTo(hash)
  $scope.contact =
    name: ''
    email: ''
    message: ''
  $scope.submitted = false
  $scope.showForm = true
  $scope.showSuccessMessage = false
  $scope.showErrorMessage = false
  $scope.executeContact = ->
    me = this
    me.submitted = true
    me.contactForm.$setDirty( true )
    return if me.contactForm.$invalid
    newContactResource = new ContactResource(me.contact)
    newContactResource.$save().then(
      (response) ->
        $scope.showForm = false
        $scope.showSuccessMessage = true
    ).catch(
      (error) ->
        $scope.showForm = false
        $scope.showErrorMessage = true
    )
ContactCtrl.$inject = ['$scope', '$http', 'ContactResource', '$location', 'AnchorSmoothScroll']


ContactResource = ( $resource, env ) ->
  $resource( "#{env.getApiBaseUrl()}/contact" )
ContactResource.$inject = ['$resource', 'env']

Config = ( $stateProvider, USER_ROLES ) ->
  $stateProvider.state( 'contact',
    url: '/contact'
    views:
      main:
        controller: 'ContactCtrl'
        templateUrl: 'app/contact/contact.html'
    data:
      pageTitle: 'Contact'
  )
Config.$inject = ['$stateProvider', 'USER_ROLES']

angular.module( 'ngJoukou.contact', [
  'ui.router'
  'ngJoukou.auth'
  'ngJoukou.env'
  'ngResource'
] )
.config( Config )
.factory( 'ContactResource', ContactResource)
.controller( 'ContactCtrl', ContactCtrl)
