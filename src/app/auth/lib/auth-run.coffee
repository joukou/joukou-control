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
Run = ( $rootScope, AUTH_EVENTS, AuthService, $window, $location, $http ) ->
  ###*
  Check authorizedRoles every time the route changes (i.e. the user navigates
  to another page). This involves listening to the `$stateChangeStart` event.
  ###
  $rootScope.$on( '$stateChangeStart', ( event, next ) ->
    if not next or not next.data
      return
    authorizedRoles = next.data.authorizedRoles
    if authorizedRoles and not AuthService.isAuthorized( authorizedRoles )
      event.preventDefault()
      if AuthService.isAuthenticated()
        # user is not allowed
        $rootScope.$broadcast(AUTH_EVENTS.notAuthorized)
      else
        # user is not signed in
        $rootScope.$broadcast(AUTH_EVENTS.notAuthenticated)
  )


  $rootScope.$broadcast(AUTH_EVENTS.authenticationChange)

  $window.addEventListener("message",  ( e ) ->
    if not e or not e.data or not e.data.auth
      return
    AuthService.signin(e.data.token, e.data.role or 'admin')
    $rootScope.$apply( ->
      $location.url("persona")
    )
  )

Run.$inject = ['$rootScope', 'AUTH_EVENTS', 'AuthService', '$window', '$location', '$http']

angular.module( 'ngJoukou.auth')
.run(Run)