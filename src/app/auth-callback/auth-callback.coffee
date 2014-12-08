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
AuthCtrl = ($scope, $stateParams, $window, $log) ->
  success = no
  token = ""
  role = "admin"
  if $stateParams and $stateParams.token
    #Set token
    $log.log($stateParams.token)
    success = yes
    token = $stateParams.token
    if $stateParams.role
      role = $stateParams.role
  origin = $window.opener or $window.parent
  originUrl = $window.location.origin
  if origin and origin.location
    originUrl = origin.location.origin
  else if origin and origin.document and origin.document.location
    originUrl = origin.document.location.origin
  if not origin
    originUrl = $window.location.origin
  origin.postMessage(
    success: success
    token: token
    auth: true
    role: role,
    originUrl
  )
  $window.close()
AuthCtrl.$inject = ['$scope', '$stateParams', '$window', '$log']

Config = ( $stateProvider ) ->
  $stateProvider
  .state( 'auth-success',
    url: '/auth/callback/success/:token'
    views:
      main:
        controller: 'AuthCtrl'
        templateUrl: 'app/auth-callback/auth-callback.html'
  )
  .state( 'auth-failed',
    url: '/auth/callback/failed'
    views:
      main:
        controller: 'AuthCtrl'
        templateUrl: 'app/auth-callback/auth-callback.html'
  )
Config.$inject = ['$stateProvider']

angular.module("ngJoukou.authCallback", [
  'ui.router'
] )
.config(Config)
.controller('AuthCtrl', AuthCtrl)