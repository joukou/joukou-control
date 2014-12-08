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
AnchorSmoothScroll = ->
  @scrollTo = (eID, animateOnlyIfUnder, $anchorScroll) ->
    animateOnlyIfUnder ?= false
    # This scrolling function
    # is from http://www.itnewb.com/tutorial/Creating-the-Smooth-Scroll-Effect-with-JavaScript
    # Fabian, added animateOnlyIfUnder, translated to coffeescript
    # Use animateOnlyIfUnder is you just want to call a function (like $anchorScroll)
    # if you don't want animation to scroll to the element when the element is lower then current Y
    currentYPosition = ->

      # Firefox, Chrome, Opera, Safari
      return self.pageYOffset  if self.pageYOffset

      # Internet Explorer 6 - standards mode
      return document.documentElement.scrollTop  if document.documentElement and document.documentElement.scrollTop

      # Internet Explorer 6, 7 and 8
      return document.body.scrollTop  if document.body.scrollTop
      0
    elmYPosition = (eID) ->
      elm = document.getElementById(eID)
      if(not elm)
        console.warn("##{eID} does not exists")
        return -1
      y = elm.offsetTop
      node = elm
      while node.offsetParent and node.offsetParent isnt document.body
        node = node.offsetParent
        y += node.offsetTop
      y
    startY = currentYPosition()
    stopY = elmYPosition(eID)
    if(stopY is -1)
      return
    if(animateOnlyIfUnder and not not $anchorScroll)
      if(stopY > startY)
        # scroll straight to, could be new page reload
        $anchorScroll()
        return
    distance = (if stopY > startY then stopY - startY else startY - stopY)
    if distance < 100
      scrollTo(0, stopY)
      return
    speed = Math.round(distance / 40)
    speed = 20  if speed >= 20
    step = Math.round(distance / 25)
    leapY = (if stopY > startY then startY + step else startY - step)
    timer = 0
    if stopY > startY
      i = startY
      while i < stopY
        setTimeout("window.scrollTo(0, " + leapY + ")", timer * speed)
        leapY += step
        leapY = stopY  if leapY > stopY
        timer++
        i += step
      return
    i = startY
    while i > stopY
      setTimeout("window.scrollTo(0, " + leapY + ")", timer * speed)
      leapY -= step
      leapY = stopY  if leapY < stopY
      timer++
      i -= step
    return
  return

AnchorSmoothScroll.$inject = []

angular.module('ngJoukou')
.service('AnchorSmoothScroll', AnchorSmoothScroll)