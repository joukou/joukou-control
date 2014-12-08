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
AuthService = ( $http, $rootScope, AUTH_EVENTS, $window, Session ) ->
  ###*
  This service contains all the logic related to authentication and
  authorization.
  ###
  signout: ->
    ## TODO
    # console.warn("Please someone implement this")
    Session.destroy()
    $rootScope.$broadcast(AUTH_EVENTS.signoutSuccess)
    $rootScope.$broadcast(AUTH_EVENTS.authenticationChange)
    Session.destroy()
  signin: ( token, role = 'admin' ) ->
    ###
    $http
      .post( '/authenticate', credentials )
      .then( ( res ) ->
        AuthSession.create( res.token )
      )
    ###
    Session.create(token)
    $rootScope.$broadcast(AUTH_EVENTS.signinSuccess)
    $rootScope.$broadcast(AUTH_EVENTS.authenticationChange)
  isAuthenticated: ->
    !!Session.token
  getToken: ->
    Session.token
  isAuthorized: ( authorizedRoles ) ->
    true

AuthService.$inject = [ '$http', '$rootScope', 'AUTH_EVENTS', '$window', 'Session' ]

angular.module( 'ngJoukou.auth')
.factory('AuthService', AuthService)