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
#cloned from control.shipper
Session = ->
  this.token = localStorage.getItem("AUTH_TOKEN")
  # TODO authenticate token
  this.create = (token) ->
    localStorage.setItem("AUTH_TOKEN", token)
    this.token = token
  this.destroy = ->
    localStorage.removeItem("AUTH_TOKEN")
    this.token = null
  return this

Session.$inject = []

angular.module("ngJoukou.auth")
.service('Session', Session)