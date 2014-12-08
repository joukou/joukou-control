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
ProcessController = ($scope, env, $stateParams, $log, $http) ->
  $scope.isCloned = (process) ->
    if not process
      return false
    return $scope.isClonedProcessID(process.id)
  $scope.isClonedProcessID = (processId) ->
    if not processId
      return false
    # If the id contains _ that means they have appended an ID
    # to the component id like bbfe54f3-7f14-4235-8377-cd88e80a5268_ppmhk
    # A normal id would be /persona/uuid/graph/uuid/process/uuid
    return processId.indexOf('_') isnt -1
  $scope.getCreateProcessLink = ->
    graphResponseLinks = $scope.graphData.links
    graphResponseLinks['joukou:process-create'][0]
  $scope.getProcessLink = (process) ->
    processLinks = process.links
    processLinks['joukou:process'][0]
  $scope.getCreateProcessPostData = (circle) ->
    selfLink = circle.links.self
    postData =
      '_links':
        'joukou:circle': [
          {
            href: selfLink.href
          }
        ]
      metadata:
        x: $scope.defaultCircleX
        y: $scope.defaultCircleY
    JSON.stringify(postData)
  $scope.addProcessToGraph = (circle, process) ->
    processLink = $scope.getProcessLink(process)
    position = $scope.getDefaultCirclePosition()
    router = new routes()
    router.addRoute('/persona/:personaKey/graph/:graphKey/process/:processKey', -> )
    match = router.match(processLink.href)
    if not match
      return
    node =
      id: processLink.href
      component: circle.props.name
      metadata:
        key: match.params.processKey
        label: circle.props.name
        x: position.x
        y: position.y
    $scope.editor.addNewNode(node)
  $scope.removeProcess = ( process ) ->
    remove = new Hyperagent.Resource("#{env.getApiBaseUrl()}/persona/#{$stateParams.persona}/graph/#{$stateParams.graph}/process/#{process.metadata.key}")
    remove.del( process )
    .then( ->
      $log.debug( "process deleted ", process )
    )
    .catch( (error) ->
      $log.warn( "Error fetching API ", error )
    )
  $scope.addProcessToEmbedded = (process) ->
    ###
    resource = Hyperagent.Resource({
      url: $scope.graphData.url()
    })
    resource.link("self", $scope.getProcessLink(process))
    resource.link("joukou:process-update:position", "#{$scope.getProcessLink(process)}/position")
    $scope.graphData.embedded["joukou:process"].push(resource)
    ###
    ($scope.processMap ?= {})[process.links["joukou:process"][0].href] = {
      self: process.links["joukou:process"][0].href
      update: process.links["joukou:process-update:position"][0].href
      updateLink: process.links["joukou:process-update:position"][0]
    }
    $scope.newProcesses.push(process)
  $scope.getUpdatePositionLink = (key) ->
    resource = $scope.graphData
    processes = resource.embedded["joukou:process"]
    process = _.where(processes,(process) ->
      process.links.self.href is key
    )[0]
    if not process
      p = $scope.processMap[key]
      if not p
        return
      return p.updateLink
    return process.links["joukou:process-update:position"]
  $scope.moveProcess = (detail) ->
    link = $scope.getUpdatePositionLink(detail.key)
    if not link
      return
    link.fetch({
      ajax: {
        type: "PUT"
        data: JSON.stringify({
          x: detail.x
          y: detail.y
        })
      }
    })
    .then(->)
    .catch(->)

  $scope.clone = (paste) ->
    link = $scope.graphData.links["joukou:process-clone"]
    link.fetch({
      ajax: {
        type: "POST"
        data: JSON.stringify(paste)
      }
    })
    .then((response) ->
      data = response.props
      for key of data.processes
        if not data.processes.hasOwnProperty(key)
          continue
        node = data.processes[key]
        $scope.processMap[node.metadata.nodeId] = {
          self: node.id
          update: "#{node.id}/position"
          updateLink: new Hyperagent.Resource("#{env.getApiBaseUrl()}/#{node.id}/position")
        }
    )


ProcessController.$inject = [ '$scope', 'env', '$stateParams', '$log', '$http' ]
angular.module('ngJoukou.grapheditor')
.controller('ProcessController', ProcessController)