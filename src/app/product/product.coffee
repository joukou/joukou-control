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
ProductCtrl = ($scope, $location, AnchorSmoothScroll) ->
  ###*
   The controller for the product page.
   ###
  $scope.scrollTo = (hash) ->
    $location.hash(hash)
    AnchorSmoothScroll.scrollTo(hash)
ProductCtrl.$inject = ['$scope', '$location', 'AnchorSmoothScroll']

Config = ( $stateProvider ) ->
  $stateProvider
    .state( 'product',
      url: '/product'
      views:
        main:
          controller: 'ProductCtrl'
          templateUrl: 'app/product/product.html'
      data:
        pageTitle: 'Product'
    )
Config.$inject = ['$stateProvider']

angular.module( 'ngJoukou.product', [
  'ui.router'
] )
.config(Config)
.controller( 'ProductCtrl', ProductCtrl)
