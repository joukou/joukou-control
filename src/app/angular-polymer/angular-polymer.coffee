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
AngularPolymerCtrl = ($scope) ->

AngularPolymerCtrl.$inject = [ '$scope' ]

Config = ($stateProvider) ->
  $stateProvider.state( 'angular-polymer',
    url: '/angular-polymer'
    views:
      main:
        controller: 'AngularPolymerCtrl'
        templateUrl: 'app/angular-polymer/angular-polymer.html'
    data:
      pageTitle: 'Angular-Polymer Two-way Data Binding Test'
  )
Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.angularPolymer', [
  'ui.router'
  'ngJoukou.auth'
] )
.config(Config)
.controller( 'AngularPolymerCtrl', AngularPolymerCtrl)