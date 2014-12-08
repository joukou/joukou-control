"use strict"
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
Polymer( 'joukou-graph-editor',
  created: ->
    @_state = {
      scale: 1,
      x: 0,
      y: 0
    }
    window.addEventListener('resize', @resizeToFitWindow.bind(@))
    @setDefaultSize()
  setDefaultSize: ->
    @setAttribute('width',window.innerWidth)
    @setAttribute('height',window.innerHeight - 55)
  resizeToFitWindow: ->
    @setAttribute('width',window.innerWidth)
    @setAttribute('height',window.innerHeight - 55)
  getState: ->
    return _.cloneDeep(@_state)
  setState: (scale, x, y) ->
    @_state = {
      scale: if scale is undefined or scale is null then 1 else scale
      x: x or 0
      y: y or 0
    }
    graph = @getGraph()
    if graph and graph.appView
      graph.appView.setState(@_state)
    else
      @_setState = yes
  ready: ->
    graph = @getGraph()
    @overrideTheGraph()
  onGraphReady: ->
    graph = @getGraph()
    graph.appView.setState(@_state)
    @_setState = no
    @.addGraphListeners()
  addGraphListeners: ->
    nofloGraph = @getNoflowGraph()
    nofloGraph.on('removeNode', @onNodeRemoved.bind(@) )
    nofloGraph.on('addEdge', @addEdge.bind(@) )
    nofloGraph.on('addNode', @addNode.bind(@) )
    nofloGraph.on('removeEdge', @removeEdge.bind(@) )
    nofloGraph.on('addOutport', @addOutport.bind(@))
    nofloGraph.on('addInport', @addInport.bind(@))
    nofloGraph.on('removeOutport', @removeOutport.bind(@))
    nofloGraph.on('removeInport', @removeInport.bind(@))
  _processEvent: (event) ->
    event = event or {}
    if event.stopPropagation
      event.stopPropagation()
    event = event.originalEvent or event
    event.detail = event.detail or {}
    while event.detail.detail instanceof Object
      event = event.detail
    return event
  addOutport: (key, port) ->
    @emit('addOutport', {
      key: key,
      value: port
    })
  addInport: (key, port) ->
    @emit('addInport', {
      key: key,
      value: port
    })
  removeOutport: (key, port) ->
    @emit('removeOutport', {
      key: key,
      value: port
    })
  removeInport: (key, port) ->
    @emit('removeInport', {
      key: key,
      value: port
    })
  onNodeRemoved: (event) ->
    @emit('nodeRemoved', event)
  addEdge: (event) ->
    @emit('addConnection', event)
  addNode: (event) ->
    @emit('addNode', event)
  removeEdge: (event) ->
    @emit('removeConnection', event)
  onStateChanged: (x, y, scale) ->
    if @_setState
      return
    state = {
      x: x
      y: y
      scale: scale
    }
    if state.x is @_state.x and state.y is @_state.y and state.scale is @_state.scale
      return
    @_state.dirty = yes
    @_state = state = {
      x: state.x
      y: state.y
      scale: state.scale
    }
    setTimeout(=>
      if state.dirty
        return
      @emit('stateChanged', event)
    , 200)
  emit: (name, detail) ->
    if not detail
      return
    if detail && detail.detail
      detail = @_processEvent(detail)
      detail = detail.detail
    event = new CustomEvent(
      name,
      {
        detail: detail
      }
    )
    @dispatchEvent(event)
  graphdataChanged: (oldVal, newVal) ->
    @loadGraph(newVal)
  addComponentsToLibrary: (components) ->
    graph = @getGraph()
    for key of components
      if not components.hasOwnProperty(key)
        continue
      graph.library[key] = components[key]
  loadGraph: (graphdata) ->
    return if graphdata == null or graphdata == undefined  or graphdata == ''
    editor = @getEditor()
    editor.graph = JSON.parse(graphdata)
  addNewNode: (node) ->
    return if node == null or node == undefined  or node == ''
    nofloGraph = @getNoflowGraph()
    nofloGraph.addNode(node.id,node.component,node.metadata)
  addNewComponent: (component) ->
    return if component == null or component == undefined  or component == ''
    graph = @getGraph()
    graph.library = {} if graph.library == null or graph.library == undefined
    graph.library[component.name] = component
  getEditor: ->
    if not @editor
      @editor = @$.editor
    return @$.editor
  getNoflowGraph: ->
    editor = @getEditor()
    editor.nofloGraph
  getGraph: ->
    editor = @getEditor()
    editor.$.graph
  overrideTheGraph: ->
    @overrideTheGraphChange()
    @overrideTheGraphOnPanScale()
    @overrideTheGraphNodeShouldComponentUpdate()
    @overrideTheGraphPaste()
  overrideTheGraphChange: ->
    graph = @getGraph()
    graphChanged = graph.graphChanged.bind(graph)
    override = (oldGraph, newGraph) =>
      res = graphChanged(oldGraph, newGraph)
      @onGraphReady()
      return res
    graph.graphChanged = override
  overrideTheGraphOnPanScale: ->
    graph = @getGraph()
    onPanScale = graph.onPanScale.bind(graph)
    override = (x, y, scale) =>
      res = onPanScale(x, y, scale)
      @onStateChanged(x, y, scale)
      return res
    graph.onPanScale = override
  overrideTheGraphNodeShouldComponentUpdate: ->
    proto = TheGraph.Node.prototype
    type = proto.type
    typeProto = type.prototype
    shouldComponentUpdate = typeProto.shouldComponentUpdate
    element = @
    override = (nextProps, nextState) ->
      # this is a node, not this element
      should = shouldComponentUpdate.apply(this, [ nextProps, nextState ])
      if nextProps.x is this.props.x and nextProps.y is this.props.y
        return should
      if this.props._lastMove
        this.props._lastMove.dirty = true
      thisMove = {
        dirty: false
      }
      this.props._lastMove = thisMove
      props = this.props
      setTimeout(->
        if thisMove.dirty
          return
        element.emit('nodeMoved', props)
      , 200)
      return should
    typeProto.shouldComponentUpdate = override
  overrideTheGraphPaste: ->
    paste = TheGraph.Clipboard.paste
    override = (graph) =>
      pasted = paste(graph)
      @emit("paste", pasted)
      return pasted
    TheGraph.Clipboard.paste = override
)

