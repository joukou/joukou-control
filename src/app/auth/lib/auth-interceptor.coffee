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
AuthInterceptor = ( $rootScope, $q, AUTH_EVENTS, $window, env ) ->
  request: (config) ->
    #Add this later if it becomes a problem
    #Everything should be done in our API anyway
    #domain = env.getApiBaseUrl()
    #if config.url.indexOf(domain) is -1
    #  return config
    if config.headers not instanceof Object
      config.headers = {}
    # Circular dependency, yay
    # Have to use straight local storage
    token = $window.localStorage.getItem("AUTH_TOKEN")
    if not token
      if config.headers.Authorization
        delete config.headers.Authorization
        return config
    config.headers.Authorization = "Bearer " + token
    config

  ###*
  Simple authentication interceptor that will broadcast a notAuthenticated /
  notAuthorized event based on the HTTP response status code.
  ###
  responseError: ( response ) ->
    if response.status is 401
      $rootScope.$broadcast( AUTH_EVENTS.notAuthenticated, response )
    else if response.status is 403
      $rootScope.$broadcast( AUTH_EVENTS.notAuthorized, response )
    $q.reject( response )

AuthInterceptor.$inject = [ '$rootScope', '$q', 'AUTH_EVENTS', '$window', 'env' ]

angular.module( 'ngJoukou.auth')
.factory( 'AuthInterceptor', AuthInterceptor)