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

This is the module for the signin form.
###
SignInCtrl = ( $scope, $rootScope, AuthService, $base64, $location, ApiService ) ->
  ###*
  The controller for the signin form. It is decoupled from the actual
  authentication logic in the ngJoukou.auth module.
  Based on https://medium.com/opinionated-angularjs/7bbf0346acec
  ###
  $scope.credentials =
    email: ''
    message: ''
    password: ''
  $scope.signupForm = null
  $scope.submitted = false
  $scope.showErrorMessage = false
  $scope.existingUser = false
  $scope.apiError = null
  $scope.cannotAccessApi = ApiService.isNotAvailable()
  $scope.navigateToPersona = ->
    $location.path( "/persona" ).replace()
    $scope.$apply()
  $scope.setAuthorizationHeader = (authHeader) ->
    Hyperagent.configure("ajax", ajax = (options) ->
      options.headers = {
        Authorization: authHeader
      }
      jQuery.ajax(options)
    )
  $scope.executeLogin = ->
    _gaq.push(['_trackEvent', 'SignIn', 'Attempt', $scope.credentials.email])
    username = $scope.credentials.email
    password = $scope.credentials.password
    authHeader = 'Basic ' + $base64.encode(username + ':' + password)
    $scope.setAuthorizationHeader(authHeader)
    ApiService.executeLink('joukou:agent-authn').then(
      (user) ->
        _gaq.push(['_trackEvent', 'SignIn', 'Success', $scope.credentials.email])
        $rootScope.authenticated = true
        ApiService.saveLinks(user.links)
        $scope.navigateToPersona()
    ).fail(
      (error) ->
        _gaq.push(['_trackEvent', 'SignIn', 'Fail', $scope.credentials.email])
        #console.warn("Error fetching API root", error)
        $rootScope.authenticated = false
        $scope.apiError = 'An error has occured while contacting the API'
    )
  $scope.signin = ->
#    $scope.credentials.email = 'juan@joukou.co'
#    $scope.credentials.password = 'juantest11'
#    $scope.executeLogin()
    $scope.submitted = true
    $scope.signinForm.$setDirty( true )
    return if $scope.signinForm.$invalid
    $scope.executeLogin()

  $scope.signup = ->
    $scope.submitted = true
    $scope.signupForm.$setDirty( true )
    return if $scope.signupForm.$invalid
    _gaq.push(['_trackEvent', 'SignUp', 'Attempt', $scope.credentials.email])
    ApiService.executeLink('joukou:agent-create',{
      data: $scope.credentials
    }).then( (user) ->
      _gaq.push(['_trackEvent', 'SignUp', 'Success', $scope.credentials.email])
      $scope.executeLogin()
    )
    .fail( (error) ->
      _gaq.push(['_trackEvent', 'SignUp', 'Fail', $scope.credentials.email])
      console.warn("Error fetching API root", error)
      $scope.apiError = 'An error has occured while contacting the API'
    )
  $scope.showError = ->
    return ($scope.submitted and $scope.signupForm.$dirty and $scope.signupForm.$invalid) or $scope.cannotAccessApi or $scope.apiError
  $scope.getErrorMessage = ->
    return ""  unless $scope.showError()
    return "The API cannot be accessed at this time"  if $scope.cannotAccessApi
    return "An error has occured"  unless $scope.submitted
    return $scope.apiError  if $scope.apiError
    return "An email address is required"  if $scope.signupForm.email.$error.required
    return "Please enter a valid email address"  if $scope.signupForm.email.$error.email
    return "Password is required"  if $scope.signupForm.password.$error.required
    return "Password must be at least 6 characters"  if $scope.signupForm.password.$error.minlength
    "An error has occured"

SignInCtrl.$inject = ['$scope', '$rootScope', 'AuthService', '$base64', '$location', 'ApiService']

Config = ( $stateProvider ) ->
  $stateProvider.state( 'signin',
    url: '/signin'
    views:
      main:
        controller: 'SignInCtrl'
        templateUrl: 'app/signin/signin.html'
    data:
      pageTitle: 'Sign In'
      existingUser: true
  )
  $stateProvider.state( 'signup',
    url: '/signup'
    views:
      main:
        controller: 'SignInCtrl'
        templateUrl: 'app/signin/signin.html'
    data:
      pageTitle: 'Sign Up'
      existingUser: false
  )
Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.signin', [
  'ngJoukou.auth'
  'ui.router'
  'base64'
  'ngJoukou.api'
] )
.config(Config)
.controller( 'SignInCtrl', SignInCtrl)
