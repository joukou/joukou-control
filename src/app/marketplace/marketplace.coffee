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
MarketplaceCtrl = ( $scope, $rootScope, $location, AnchorSmoothScroll, $state ) ->
  ###*
  The controller for the marketplace page.
  ###

  $scope.isActive = (name) ->
    $state.includes(name)
  $scope.scrollTo = (hash) ->
    $location.hash(hash)
    AnchorSmoothScroll.scrollTo(hash)

MarketplaceCtrl.$inject = ['$scope', '$rootScope', '$location', 'AnchorSmoothScroll', '$state']


Config = ($stateProvider) ->
  $stateProvider
  .state( 'marketplace',
    url: '/marketplace'
    views:
      main:
        controller: 'MarketplaceCtrl'
        templateUrl: 'app/marketplace/marketplace.html'
    data:
      pageTitle: 'Marketplace'
  )
  .state( 'marketplace-connectors',
    url: '/marketplace/connectors'
    views:
      main:
        controller: 'MarketplaceCtrl'
        templateUrl: 'app/marketplace/connectors.html'
    data:
      pageTitle: 'Marketplace - Connectors'
  )
  .state( 'marketplace-developers',
    url: '/marketplace/developers'
    views:
      main:
        controller: 'MarketplaceCtrl'
        templateUrl: 'app/marketplace/developers.html'
    data:
      pageTitle: 'Marketplace - Developers'
  )
  .state( 'marketplace-partners',
    url: '/marketplace/partners'
    views:
      main:
        controller: 'MarketplaceCtrl'
        templateUrl: 'app/marketplace/partners.html'
    data:
      pageTitle: 'Marketplace - Partners'
  )

Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.marketplace', [
  'ui.router'
] )
.config(Config)
.controller( 'MarketplaceCtrl', MarketplaceCtrl)
