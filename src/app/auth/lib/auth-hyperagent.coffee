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
AuthHyperagent = (AuthService, $q) ->
  if Hyperagent.Resource.joukouResource
    return Hyperagent
  Hyperagent.configure('defer', $q.defer)
  hyperAgentResource = Hyperagent.Resource
  Hyperagent.Resource = (args) ->
    if args instanceof Object
      # Set auth header
      args.headers = args.headers or {}
    else if typeof args is "string"
      args = {
        url: args
        headers: { }
      }
    else
      # This shouldn't even happen.
      # Let Hyper-agent throw the right
      # error
      args = {
        headers: {}
      }
    setToken = ->
      Object.defineProperty(args.headers, "Authorization", {
        get: ->
          token = AuthService.getToken()
          if not token
            return token
          return "Bearer " + token
        set: (val) ->
          throw new Error("Cannot change auth header")
        enumerable: true
      })
    args.headers.Accept = "application/hal+json, application/json"
    args.headers["Content-Type"] = "application/json"
    if AuthService.getToken() isnt args.headers.Authorization
      setToken()
    # args.headers["throwOffCache"] = new Date().getTime()
    haResource = new hyperAgentResource(args)
    haResource.ajax = (type, data) ->
      if data is undefined
        data = ""
      else if data is null
        data = ""
      if typeof data isnt 'string'
        data = JSON.stringify(data)
      return haResource.fetch({
        ajax: {
          type: type
          data: data
        }
      })
    haResource.del = (data) ->
      return haResource.ajax("DELETE", data)
    haResource.post = (data) ->
      return haResource.ajax("POST", data)
    haResource.put = (data) ->
      return haResource.ajax("PUT", data)
    haResource.get = (data) ->
      return haResource.ajax("GET", data)
    oldParse = haResource._parse
    haResource._parse = (data) ->
      if data is undefined or data is null
        return {}
      return oldParse.apply(haResource, [ data ])
    return haResource
  Hyperagent.Resource.joukouResource = true
  return Hyperagent

AuthHyperagent.$inject = ['AuthService', '$q']

angular.module( 'ngJoukou.auth')
.service("Hyperagent", AuthHyperagent)