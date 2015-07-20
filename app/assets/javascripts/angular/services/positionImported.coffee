angular.module('ui.bootstrap.position', []).factory '$position', [
  '$document'
  '$window'
  ($document, $window) ->

    ###*
    # returns the closest, non-statically positioned parentOffset of a given element
    # @param element
    ###

    parentOffsetEl = (element) ->
      docDomEl = $document[0]
      offsetParent = element.offsetParent or docDomEl
      while offsetParent and offsetParent != docDomEl and isStaticPositioned(offsetParent)
        offsetParent = offsetParent.offsetParent
      offsetParent or docDomEl

    getStyle = (el, cssprop) ->
      if el.currentStyle
        #IE
        return el.currentStyle[cssprop]
      else if $window.getComputedStyle
        return $window.getComputedStyle(el)[cssprop]
      # finally try and get inline style
      el.style[cssprop]

    ###*
    # Checks if a given element is statically positioned
    # @param element - raw DOM element
    ###

    isStaticPositioned = (element) ->
      (getStyle(element, 'position') or 'static') == 'static'

    {
      position: (element) ->
        elBCR = @offset(element)
        offsetParentBCR = 
          top: 0
          left: 0
        offsetParentEl = parentOffsetEl(element[0])
        if offsetParentEl != $document[0]
          offsetParentBCR = @offset(angular.element(offsetParentEl))
          offsetParentBCR.top += offsetParentEl.clientTop - (offsetParentEl.scrollTop)
          offsetParentBCR.left += offsetParentEl.clientLeft - (offsetParentEl.scrollLeft)
        boundingClientRect = element[0].getBoundingClientRect()
        {
          width: boundingClientRect.width or element.prop('offsetWidth')
          height: boundingClientRect.height or element.prop('offsetHeight')
          top: elBCR.top - (offsetParentBCR.top)
          left: elBCR.left - (offsetParentBCR.left)
        }
      offset: (element) ->
        boundingClientRect = element[0].getBoundingClientRect()
        {
          width: boundingClientRect.width or element.prop('offsetWidth')
          height: boundingClientRect.height or element.prop('offsetHeight')
          top: boundingClientRect.top + ($window.pageYOffset or $document[0].documentElement.scrollTop)
          left: boundingClientRect.left + ($window.pageXOffset or $document[0].documentElement.scrollLeft)
        }
      positionElements: (hostEl, targetEl, positionStr, appendToBody) ->
        positionStrParts = positionStr.split('-')
        pos0 = positionStrParts[0]
        pos1 = positionStrParts[1] or 'center'
        hostElPos = undefined
        targetElWidth = undefined
        targetElHeight = undefined
        targetElPos = undefined
        hostElPos = if appendToBody then @offset(hostEl) else @position(hostEl)
        targetElWidth = targetEl.prop('offsetWidth')
        targetElHeight = targetEl.prop('offsetHeight')
        shiftWidth = 
          center: ->
            hostElPos.left + hostElPos.width / 2 - (targetElWidth / 2)
          left: ->
            hostElPos.left
          right: ->
            hostElPos.left + hostElPos.width
        shiftHeight = 
          center: ->
            hostElPos.top + hostElPos.height / 2 - (targetElHeight / 2)
          top: ->
            hostElPos.top
          bottom: ->
            hostElPos.top + hostElPos.height
        switch pos0
          when 'right'
            targetElPos =
              top: shiftHeight[pos1]()
              left: shiftWidth[pos0]()
          when 'left'
            targetElPos =
              top: shiftHeight[pos1]()
              left: hostElPos.left - targetElWidth
          when 'bottom'
            targetElPos =
              top: shiftHeight[pos0]()
              left: shiftWidth[pos1]()
          else
            targetElPos =
              top: hostElPos.top - targetElHeight
              left: shiftWidth[pos1]()
            break
        targetElPos

    }
]
