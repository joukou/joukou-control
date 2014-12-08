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
FooterCtrl = ( $scope, $location, env ) ->
  $scope.disableSignIn = env.disableSignIn()
  $scope.credentials =
    name: ''
    email: ''
    message: ''
    password: ''
  $scope.submitted = false
  $scope.showForm = true
  $scope.showSuccessMessage = false
  $scope.showErrorMessage = false
  $scope.showSignUp = false
  $scope.signup = ->
    $scope.submitted = true
    $scope.signupForm.$setDirty( true )
    return if $scope.signupForm.$invalid
    newSignUpResource = new SignUpResource($scope.credentials)
    newSignUpResource.$save().then(
      (response) ->
        $scope.showForm = false
        $scope.showSuccessMessage = true
    ).catch(
      (error) ->
        $scope.showForm = false
        $scope.showErrorMessage = true
    )
  $scope.location = ->
    $location.path().replace(/^\//, '')

FooterCtrl.$inject = ['$scope', '$location', 'env']

angular.module( 'ngJoukou.footer', [ ] )
.controller( 'FooterCtrl', FooterCtrl)
