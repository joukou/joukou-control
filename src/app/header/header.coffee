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
HeaderCtrl = ( $scope, $rootScope, AuthService, $base64, $location, ApiService, $state, env, $window, AUTH_EVENTS ) ->
  $scope.disableSignIn = env.disableSignIn()
  $scope.credentials =
    message: ''
    password: ''
  $scope.authenticated = AuthService.isAuthenticated()
  $scope.submitted = false
  $scope.showErrorMessage = false
  $scope.existingUser = true
  $scope.showSignout = !!AuthService.signout
  $scope.showMobileNavBar
  $scope.isActive = (loc) ->
    locationMod = $location.path().replace(/^\//, "")
    if loc.indexOf("/") > -1
      loc is locationMod
    else if loc.indexOf("-") > -1
      $state.includes(loc)
    else if locationMod.indexOf("/") > -1
      locationMod.substring(0, locationMod.indexOf("/")) is loc
    else
      $state.includes(loc)
  $scope.navigateToPersona = ->
    $location.path( "/persona" ).replace()
    $scope.$apply()
  # I was having troubles with the form not coming up in the scope..
  $scope.setFormScope = (form) ->
    $scope.signinForm = form
  $scope.executeLogin = ->
    width = Math.min(1000, screen.width)
    height = Math.min(750, screen.height)
    left = ( screen.width / 2 ) - ( width / 2 )
    top = ( screen.height / 2 ) - ( height / 2 )
    windowParams =  "toolbar=no, "
    windowParams += "location=no, "
    windowParams += "directories=no, "
    windowParams += "status=no, "
    windowParams += "menubar=no, "
    windowParams += "resizable=yes, "
    windowParams += "copyhistory=no, "
    windowParams += "width=" + width + ", "
    windowParams += "height=" + height + ", "
    windowParams += "top=" + top + ", "
    windowParams += "left=" + left
    $window.open(env.getApiBaseUrl() + "/agent/authenticate", "AuthWindow", windowParams)
    # CoffeeScript would usually return Window which isn't allowed in angular
    true
  $scope.signin = ->
    $scope.executeLogin()
  $scope.signout = ->
    AuthService.signout()
  $rootScope.$on(AUTH_EVENTS.authenticationChange, ->
    $scope.authenticated = AuthService.isAuthenticated()
  )

HeaderCtrl.$inject = [
  '$scope',
  '$rootScope',
  'AuthService',
  '$base64',
  '$location',
  'ApiService',
  '$state',
  'env',
  '$window',
  'AUTH_EVENTS'
]

angular.module( 'ngJoukou.header', [
  'ui.bootstrap.dropdown'
  'ngJoukou.auth'
  'ui.router'
  'base64'
  'ngJoukou.api'
] )
.controller( 'HeaderCtrl', HeaderCtrl)
