do ->

  ###*
  # Config
  ###

  moduleName = 'angularUtils.directives.dirPagination'
  DEFAULT_ID = '__default'

  ###*
  # Module
  ###

  module = undefined

  dirPaginateDirective = ($compile, $parse, paginationService) ->

    dirPaginationCompileFn = (tElement, tAttrs) ->
      expression = tAttrs.dirPaginate
      # regex taken directly from https://github.com/angular/angular.js/blob/master/src/ng/directive/ngRepeat.js#L211
      match = expression.match(/^\s*([\s\S]+?)\s+in\s+([\s\S]+?)(?:\s+track\s+by\s+([\s\S]+?))?\s*$/)
      filterPattern = /\|\s*itemsPerPage\s*:[^|\)]*/
      if match[2].match(filterPattern) == null
        throw 'pagination directive: the \'itemsPerPage\' filter must be set.'
      itemsPerPageFilterRemoved = match[2].replace(filterPattern, '')
      collectionGetter = $parse(itemsPerPageFilterRemoved)
      addNoCompileAttributes tElement
      # If any value is specified for paginationId, we register the un-evaluated expression at this stage for the benefit of any
      # dir-pagination-controls directives that may be looking for this ID.
      rawId = tAttrs.paginationId or DEFAULT_ID
      paginationService.registerInstance rawId
      (scope, element, attrs) ->
        # Now that we have access to the `scope` we can interpolate any expression given in the paginationId attribute and
        # potentially register a new ID if it evaluates to a different value than the rawId.
        paginationId = $parse(attrs.paginationId)(scope) or attrs.paginationId or DEFAULT_ID
        paginationService.registerInstance paginationId
        repeatExpression = getRepeatExpression(expression, paginationId)
        addNgRepeatToElement element, attrs, repeatExpression
        removeTemporaryAttributes element
        compiled = $compile(element)
        currentPageGetter = makeCurrentPageGetterFn(scope, attrs, paginationId)
        paginationService.setCurrentPageParser paginationId, currentPageGetter, scope
        if typeof attrs.totalItems != 'undefined'
          paginationService.setAsyncModeTrue paginationId
          scope.$watch (->
            $parse(attrs.totalItems) scope
          ), (result) ->
            if 0 <= result
              paginationService.setCollectionLength paginationId, result
            return
        else
          scope.$watchCollection (->
            collectionGetter scope
          ), (collection) ->
            if collection
              paginationService.setCollectionLength paginationId, collection.length
            return
        # Delegate to the link function returned by the new compilation of the ng-repeat
        compiled scope
        return

    ###*
    # If a pagination id has been specified, we need to check that it is present as the second argument passed to
    # the itemsPerPage filter. If it is not there, we add it and return the modified expression.
    #
    # @param expression
    # @param paginationId
    # @returns {*}
    ###

    getRepeatExpression = (expression, paginationId) ->
      repeatExpression = undefined
      idDefinedInFilter = ! !expression.match(/(\|\s*itemsPerPage\s*:[^|]*:[^|]*)/)
      if paginationId != DEFAULT_ID and !idDefinedInFilter
        repeatExpression = expression.replace(/(\|\s*itemsPerPage\s*:[^|]*)/, '$1 : \'' + paginationId + '\'')
      else
        repeatExpression = expression
      repeatExpression

    ###*
    # Adds the ng-repeat directive to the element. In the case of multi-element (-start, -end) it adds the
    # appropriate multi-element ng-repeat to the first and last element in the range.
    # @param element
    # @param attrs
    # @param repeatExpression
    ###

    addNgRepeatToElement = (element, attrs, repeatExpression) ->
      if element[0].hasAttribute('dir-paginate-start') or element[0].hasAttribute('data-dir-paginate-start')
        # using multiElement mode (dir-paginate-start, dir-paginate-end)
        attrs.$set 'ngRepeatStart', repeatExpression
        element.eq(element.length - 1).attr 'ng-repeat-end', true
      else
        attrs.$set 'ngRepeat', repeatExpression
      return

    ###*
    # Adds the dir-paginate-no-compile directive to each element in the tElement range.
    # @param tElement
    ###

    addNoCompileAttributes = (tElement) ->
      angular.forEach tElement, (el) ->
        if el.nodeType == 1
          angular.element(el).attr 'dir-paginate-no-compile', true
        return
      return

    ###*
    # Removes the variations on dir-paginate (data-, -start, -end) and the dir-paginate-no-compile directives.
    # @param element
    ###

    removeTemporaryAttributes = (element) ->
      angular.forEach element, (el) ->
        if el.nodeType == 1
          angular.element(el).removeAttr 'dir-paginate-no-compile'
        return
      element.eq(0).removeAttr('dir-paginate-start').removeAttr('dir-paginate').removeAttr('data-dir-paginate-start').removeAttr 'data-dir-paginate'
      element.eq(element.length - 1).removeAttr('dir-paginate-end').removeAttr 'data-dir-paginate-end'
      return

    ###*
    # Creates a getter function for the current-page attribute, using the expression provided or a default value if
    # no current-page expression was specified.
    #
    # @param scope
    # @param attrs
    # @param paginationId
    # @returns {*}
    ###

    makeCurrentPageGetterFn = (scope, attrs, paginationId) ->
      currentPageGetter = undefined
      if attrs.currentPage
        currentPageGetter = $parse(attrs.currentPage)
      else
        # if the current-page attribute was not set, we'll make our own
        defaultCurrentPage = paginationId + '__currentPage'
        scope[defaultCurrentPage] = 1
        currentPageGetter = $parse(defaultCurrentPage)
      currentPageGetter

    {
      terminal: true
      multiElement: true
      compile: dirPaginationCompileFn
    }

  ###*
  # This is a helper directive that allows correct compilation when in multi-element mode (ie dir-paginate-start, dir-paginate-end).
  # It is dynamically added to all elements in the dir-paginate compile function, and it prevents further compilation of
  # any inner directives. It is then removed in the link function, and all inner directives are then manually compiled.
  ###

  noCompileDirective = ->
    {
      priority: 5000
      terminal: true
    }

  dirPaginationControlsTemplateInstaller = ($templateCache) ->
    $templateCache.put 'angularUtils.directives.dirPagination.template', '<ul class="pagination" ng-if="1 < pages.length || !autoHide"><li ng-if="boundaryLinks" ng-class="{ disabled : pagination.current == 1 }"><a href="" ng-click="setCurrent(1)">&laquo;</a></li><li ng-if="directionLinks" ng-class="{ disabled : pagination.current == 1 }"><a href="" ng-click="setCurrent(pagination.current - 1)">&lsaquo;</a></li><li ng-repeat="pageNumber in pages track by $index" ng-class="{ active : pagination.current == pageNumber, disabled : pageNumber == \'...\' || ( ! autoHide && pages.length === 1 ) }"><a href="" ng-click="setCurrent(pageNumber)">{{ pageNumber }}</a></li><li ng-if="directionLinks" ng-class="{ disabled : pagination.current == pagination.last }"><a href="" ng-click="setCurrent(pagination.current + 1)">&rsaquo;</a></li><li ng-if="boundaryLinks"  ng-class="{ disabled : pagination.current == pagination.last }"><a href="" ng-click="setCurrent(pagination.last)">&raquo;</a></li></ul>'
    return

  dirPaginationControlsDirective = (paginationService, paginationTemplate) ->
    numberRegex = /^\d+$/

    dirPaginationControlsLinkFn = (scope, element, attrs) ->
      # rawId is the un-interpolated value of the pagination-id attribute. This is only important when the corresponding dir-paginate directive has
      # not yet been linked (e.g. if it is inside an ng-if block), and in that case it prevents this controls directive from assuming that there is
      # no corresponding dir-paginate directive and wrongly throwing an exception.
      rawId = attrs.paginationId or DEFAULT_ID
      paginationId = scope.paginationId or attrs.paginationId or DEFAULT_ID

      goToPage = (num) ->
        if isValidPageNumber(num)
          scope.pages = generatePagesArray(num, paginationService.getCollectionLength(paginationId), paginationService.getItemsPerPage(paginationId), paginationRange)
          scope.pagination.current = num
          updateRangeValues()
          # if a callback has been set, then call it with the page number as an argument
          if scope.onPageChange
            scope.onPageChange newPageNumber: num
        return

      generatePagination = ->
        page = parseInt(paginationService.getCurrentPage(paginationId)) or 1
        scope.pages = generatePagesArray(page, paginationService.getCollectionLength(paginationId), paginationService.getItemsPerPage(paginationId), paginationRange)
        scope.pagination.current = page
        scope.pagination.last = scope.pages[scope.pages.length - 1]
        if scope.pagination.last < scope.pagination.current
          scope.setCurrent scope.pagination.last
        else
          updateRangeValues()
        return

      ###*
      # This function updates the values (lower, upper, total) of the `scope.range` object, which can be used in the pagination
      # template to display the current page range, e.g. "showing 21 - 40 of 144 results";
      ###

      updateRangeValues = ->
        currentPage = paginationService.getCurrentPage(paginationId)
        itemsPerPage = paginationService.getItemsPerPage(paginationId)
        totalItems = paginationService.getCollectionLength(paginationId)
        scope.range.lower = (currentPage - 1) * itemsPerPage + 1
        scope.range.upper = Math.min(currentPage * itemsPerPage, totalItems)
        scope.range.total = totalItems
        return

      isValidPageNumber = (num) ->
        numberRegex.test(num) and 0 < num and num <= scope.pagination.last

      if !paginationService.isRegistered(paginationId) and !paginationService.isRegistered(rawId)
        idMessage = if paginationId != DEFAULT_ID then ' (id: ' + paginationId + ') ' else ' '
        throw 'pagination directive: the pagination controls' + idMessage + 'cannot be used without the corresponding pagination directive.'
      if !scope.maxSize
        scope.maxSize = 9
      scope.autoHide = if scope.autoHide == undefined then true else scope.autoHide
      scope.directionLinks = if angular.isDefined(attrs.directionLinks) then scope.$parent.$eval(attrs.directionLinks) else true
      scope.boundaryLinks = if angular.isDefined(attrs.boundaryLinks) then scope.$parent.$eval(attrs.boundaryLinks) else false
      paginationRange = Math.max(scope.maxSize, 5)
      scope.pages = []
      scope.pagination =
        last: 1
        current: 1
      scope.range =
        lower: 1
        upper: 1
        total: 1
      scope.$watch (->
        (paginationService.getCollectionLength(paginationId) + 1) * paginationService.getItemsPerPage(paginationId)
      ), (length) ->
        if 0 < length
          generatePagination()
        return
      scope.$watch (->
        paginationService.getItemsPerPage paginationId
      ), (current, previous) ->
        if current != previous and typeof previous != 'undefined'
          goToPage scope.pagination.current
        return
      scope.$watch (->
        paginationService.getCurrentPage paginationId
      ), (currentPage, previousPage) ->
        if currentPage != previousPage
          goToPage currentPage
        return

      scope.setCurrent = (num) ->
        if isValidPageNumber(num)
          num = parseInt(num, 10)
          paginationService.setCurrentPage paginationId, num
        return

      return

    ###*
    # Generate an array of page numbers (or the '...' string) which is used in an ng-repeat to generate the
    # links used in pagination
    #
    # @param currentPage
    # @param rowsPerPage
    # @param paginationRange
    # @param collectionLength
    # @returns {Array}
    ###

    generatePagesArray = (currentPage, collectionLength, rowsPerPage, paginationRange) ->
      pages = []
      totalPages = Math.ceil(collectionLength / rowsPerPage)
      halfWay = Math.ceil(paginationRange / 2)
      position = undefined
      if currentPage <= halfWay
        position = 'start'
      else if totalPages - halfWay < currentPage
        position = 'end'
      else
        position = 'middle'
      ellipsesNeeded = paginationRange < totalPages
      i = 1
      while i <= totalPages and i <= paginationRange
        pageNumber = calculatePageNumber(i, currentPage, paginationRange, totalPages)
        openingEllipsesNeeded = i == 2 and (position == 'middle' or position == 'end')
        closingEllipsesNeeded = i == paginationRange - 1 and (position == 'middle' or position == 'start')
        if ellipsesNeeded and (openingEllipsesNeeded or closingEllipsesNeeded)
          pages.push '...'
        else
          pages.push pageNumber
        i++
      pages

    ###*
    # Given the position in the sequence of pagination links [i], figure out what page number corresponds to that position.
    #
    # @param i
    # @param currentPage
    # @param paginationRange
    # @param totalPages
    # @returns {*}
    ###

    calculatePageNumber = (i, currentPage, paginationRange, totalPages) ->
      halfWay = Math.ceil(paginationRange / 2)
      if i == paginationRange
        totalPages
      else if i == 1
        i
      else if paginationRange < totalPages
        if totalPages - halfWay < currentPage
          totalPages - paginationRange + i
        else if halfWay < currentPage
          currentPage - halfWay + i
        else
          i
      else
        i

    {
      restrict: 'AE'
      templateUrl: (elem, attrs) ->
        attrs.templateUrl or paginationTemplate.getPath()
      scope:
        maxSize: '=?'
        onPageChange: '&?'
        paginationId: '=?'
        autoHide: '=?'
      link: dirPaginationControlsLinkFn
    }

  ###*
  # This filter slices the collection into pages based on the current page number and number of items per page.
  # @param paginationService
  # @returns {Function}
  ###

  itemsPerPageFilter = (paginationService) ->
    (collection, itemsPerPage, paginationId) ->
      if typeof paginationId == 'undefined'
        paginationId = DEFAULT_ID
      if !paginationService.isRegistered(paginationId)
        throw 'pagination directive: the itemsPerPage id argument (id: ' + paginationId + ') does not match a registered pagination-id.'
      end = undefined
      start = undefined
      if collection instanceof Array
        itemsPerPage = parseInt(itemsPerPage) or 9999999999
        if paginationService.isAsyncMode(paginationId)
          start = 0
        else
          start = (paginationService.getCurrentPage(paginationId) - 1) * itemsPerPage
        end = start + itemsPerPage
        paginationService.setItemsPerPage paginationId, itemsPerPage
        collection.slice start, end
      else
        collection

  ###*
  # This service allows the various parts of the module to communicate and stay in sync.
  ###

  paginationService = ->
    instances = {}
    lastRegisteredInstance = undefined

    @registerInstance = (instanceId) ->
      if typeof instances[instanceId] == 'undefined'
        instances[instanceId] = asyncMode: false
        lastRegisteredInstance = instanceId
      return

    @isRegistered = (instanceId) ->
      typeof instances[instanceId] != 'undefined'

    @getLastInstanceId = ->
      lastRegisteredInstance

    @setCurrentPageParser = (instanceId, val, scope) ->
      instances[instanceId].currentPageParser = val
      instances[instanceId].context = scope
      return

    @setCurrentPage = (instanceId, val) ->
      instances[instanceId].currentPageParser.assign instances[instanceId].context, val
      return

    @getCurrentPage = (instanceId) ->
      parser = instances[instanceId].currentPageParser
      if parser then parser(instances[instanceId].context) else 1

    @setItemsPerPage = (instanceId, val) ->
      instances[instanceId].itemsPerPage = val
      return

    @getItemsPerPage = (instanceId) ->
      instances[instanceId].itemsPerPage

    @setCollectionLength = (instanceId, val) ->
      instances[instanceId].collectionLength = val
      return

    @getCollectionLength = (instanceId) ->
      instances[instanceId].collectionLength

    @setAsyncModeTrue = (instanceId) ->
      instances[instanceId].asyncMode = true
      return

    @isAsyncMode = (instanceId) ->
      instances[instanceId].asyncMode

    return

  ###*
  # This provider allows global configuration of the template path used by the dir-pagination-controls directive.
  ###

  paginationTemplateProvider = ->
    templatePath = 'angularUtils.directives.dirPagination.template'

    @setPath = (path) ->
      templatePath = path
      return

    @$get = ->
      { getPath: ->
        templatePath
 }

    return

  try
    module = angular.module(moduleName)
  catch err
    # named module does not exist, so create one
    module = angular.module(moduleName, [])
  module.directive('dirPaginate', [
    '$compile'
    '$parse'
    'paginationService'
    dirPaginateDirective
  ]).directive('dirPaginateNoCompile', noCompileDirective).directive('dirPaginationControls', [
    'paginationService'
    'paginationTemplate'
    dirPaginationControlsDirective
  ]).filter('itemsPerPage', [
    'paginationService'
    itemsPerPageFilter
  ]).service('paginationService', paginationService).provider('paginationTemplate', paginationTemplateProvider).run [
    '$templateCache'
    dirPaginationControlsTemplateInstaller
  ]
  return
