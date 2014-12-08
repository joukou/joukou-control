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

This is the module for the solutions page.
###
PrivacyCtrl = ($scope) ->

PrivacyCtrl.$inject = ['$scope']

Config = ( $stateProvider ) ->
  $stateProvider.state( 'privacy',
    url: '/privacy'
    views:
      main:
        controller: 'PrivacyCtrl'
        templateUrl: 'app/privacy/privacy.html'
    data:
      pageTitle: 'Privacy'
  )
Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.privacy', [
  'ui.router'
] )
.config(Config)
.controller( 'PrivacyCtrl', PrivacyCtrl)
