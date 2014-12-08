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

This module contains all the actual authentication.
Based on https://medium.com/opinionated-angularjs/7bbf0346acec
###

Config = ( $httpProvider ) ->
  ###*
    Adds AuthInterceptor to $httpProvider.
    ###
  $httpProvider.interceptors.push( [
    '$injector',
    ( $injector ) ->
      $injector.get( 'AuthInterceptor' )
  ] )
Config.$inject = ['$httpProvider']


angular.module( 'ngJoukou.auth', [ ] )
.config(Config)
.constant( 'AUTH_EVENTS',
  ###*
  Authenticating affects the state of the entire application. For this reason
  events are used (with $broadcast) to communicate changes in the user's
  session. This constant defines all the available authentication event codes.
  ###
  signinSuccess: 'auth-signin-success'
  signinFailed: 'auth-signin-failed'
  signoutSuccess: 'auth-signout-success'
  sessionTimeout: 'auth-session-timeout'
  notAuthenticated: 'auth-not-authenticated'
  notAuthorized: 'auth-not-authorized'
  authenticationChange: 'auth-changed'
)
.constant( 'USER_ROLES',
  ###*
  This constant defines all the available user roles.
  ###
  all: '*'
  admin: 'admin'
  user: 'user'
  guest: 'guest'
)


