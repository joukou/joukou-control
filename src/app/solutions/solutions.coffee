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
SolutionsCtrl = ( $scope, $rootScope, $location, AnchorSmoothScroll, $timeout, $anchorScroll, $state ) ->
  ###*
  The controller for the solutions page.
  ###
  $scope.scrollTo = (hash) ->
    $location.hash(hash)
    AnchorSmoothScroll.scrollTo(hash)
  $scope.scrollToDelayed = (hash, delay) ->
    $timeout(
      ->
        $location.hash(hash)
        AnchorSmoothScroll.scrollTo(hash)
    , delay)

  setPage = (page) ->
    switch page
      when "it", "solutions-it"
        $scope.currentPage = "it"
      when "developer", "solutions-developer"
        $scope.currentPage = "developer"
      when "business", "solutions-business"
        $scope.currentPage = "business"
  setPage($state.current.name)
  #if(not not $stateParams and not not $stateParams.scrollTo)
  if($state.current.name isnt 'solutions')
    $timeout(
      ->
        $scope.scrollTo('solutions-content-top', true)
    , 200)

SolutionsCtrl.$inject = [
  '$scope',
  '$rootScope',
  '$location',
  'AnchorSmoothScroll',
  '$timeout',
  '$anchorScroll',
  '$state'
]

Config = ( $stateProvider ) ->
  $stateProvider
  .state( 'solutions',
    url: '/solutions'
    views:
      main:
        controller: 'SolutionsCtrl'
        templateUrl: 'app/solutions/solutions.html'
    data:
      pageTitle: 'Solutions'
  )
  .state( 'solutions-business',
    url: '/solutions/business/'
    views:
      main:
        controller: 'SolutionsCtrl'
        templateUrl: 'app/solutions/solutions.html'
    data:
      pageTitle: 'Solutions - Business'
  )
  .state( 'solutions-it',
    url: '/solutions/it/'
    views:
      main:
        controller: 'SolutionsCtrl'
        templateUrl: 'app/solutions/solutions.html'
    data:
      pageTitle: 'Solutions - IT'
  )
  .state( 'solutions-developer',
    url: '/solutions/developer/'
    views:
      main:
        controller: 'SolutionsCtrl'
        templateUrl: 'app/solutions/solutions.html'
    data:
      pageTitle: 'Solutions - Developer'
  )
Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.solutions', [
  'ui.router'
] )
.config( Config )
.controller( 'SolutionsCtrl', SolutionsCtrl)
