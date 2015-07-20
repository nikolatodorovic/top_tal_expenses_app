angular.module('sy.bootstrap.timepicker', [ 'ui.bootstrap.position' ]).constant('syTimepickerConfig',
  hourStep: 1
  minuteStep: 15
  secondStep: 1
  showMeridian: false
  showSeconds: false
  meridians: null
  readonlyInput: false
  mousewheel: true).controller('syTimepickerCtrl', [
  '$scope'
  '$attrs'
  '$parse'
  '$log'
  '$locale'
  'syTimepickerConfig'
  ($scope, $attrs, $parse, $log, $locale, syTimepickerConfig) ->
    selected = new Date
    ngModelCtrl = $setViewValue: angular.noop
    meridians = if angular.isDefined($attrs.meridians) then $scope.$parent.$eval($attrs.meridians) else syTimepickerConfig.meridians or $locale.DATETIME_FORMATS.AMPMS

    getValue = (value, defaultValue) ->
      if angular.isDefined(value) then $scope.$parent.$eval(value) else defaultValue

    # Get $scope.hours in 24H mode if valid

    getHoursFromTemplate = ->
      hours = parseInt($scope.hours, 10)
      valid = if $scope.showMeridian then hours > 0 and hours < 13 else hours >= 0 and hours < 24
      if !valid
        return undefined
      if $scope.showMeridian
        if hours == 12
          hours = 0
        if $scope.meridian == meridians[1]
          hours = hours + 12
      hours

    getMinutesFromTemplate = ->
      minutes = parseInt($scope.minutes, 10)
      if minutes >= 0 and minutes < 60 then minutes else undefined

    getSecondsFromTemplate = ->
      seconds = parseInt($scope.seconds, 10)
      if seconds >= 0 and seconds < 60 then seconds else undefined

    pad = (value) ->
      if angular.isDefined(value) and value.toString().length < 2 then '0' + value else value

    # Call internally when we know that model is valid.

    refresh = (keyboardChange) ->
      makeValid()
      ngModelCtrl.$setViewValue new Date(selected)
      updateTemplate keyboardChange
      return

    makeValid = ->
      ngModelCtrl.$setValidity 'time', true
      $scope.invalidHours = false
      $scope.invalidMinutes = false
      $scope.invalidSeconds = false
      return

    updateTemplate = (keyboardChange) ->
      hours = selected.getHours()
      minutes = selected.getMinutes()
      seconds = selected.getSeconds()
      if $scope.showMeridian
        hours = if hours == 0 or hours == 12 then 12 else hours % 12
        # Convert 24 to 12 hour system
      $scope.hours = if keyboardChange == 'h' then hours else pad(hours)
      $scope.minutes = if keyboardChange == 'm' then minutes else pad(minutes)
      $scope.seconds = if keyboardChange == 's' then seconds else pad(seconds)
      $scope.meridian = if selected.getHours() < 12 then meridians[0] else meridians[1]
      return

    addMinutes = (minutes) ->
      dt = new Date(selected.getTime() + minutes * 60000)
      selected.setHours dt.getHours(), dt.getMinutes()
      refresh()
      return

    addSeconds = (seconds) ->
      dt = new Date(selected.getTime() + seconds * 1000)
      selected.setHours dt.getHours(), dt.getMinutes(), dt.getSeconds()
      refresh()
      return

    $scope.showSeconds = getValue($attrs.showSeconds, syTimepickerConfig.showSeconds)

    @init = (ngModelCtrl_, inputs) ->
      ngModelCtrl = ngModelCtrl_
      ngModelCtrl.$render = @render
      hoursInputEl = inputs.eq(0)
      minutesInputEl = inputs.eq(1)
      secondsInputEl = inputs.eq(2)
      mousewheel = if angular.isDefined($attrs.mousewheel) then $scope.$parent.$eval($attrs.mousewheel) else syTimepickerConfig.mousewheel
      if mousewheel
        @setupMousewheelEvents hoursInputEl, minutesInputEl, secondsInputEl
      $scope.readonlyInput = if angular.isDefined($attrs.readonlyInput) then scope.$parent.$eval($attrs.readonlyInput) else syTimepickerConfig.readonlyInput
      @setupInputEvents hoursInputEl, minutesInputEl, secondsInputEl
      return

    hourStep = syTimepickerConfig.hourStep
    if $attrs.hourStep
      $scope.$parent.$watch $parse($attrs.hourStep), (value) ->
        hourStep = parseInt(value, 10)
        return
    minuteStep = syTimepickerConfig.minuteStep
    if $attrs.minuteStep
      $scope.$parent.$watch $parse($attrs.minuteStep), (value) ->
        minuteStep = parseInt(value, 10)
        return
    secondStep = syTimepickerConfig.secondStep
    if $attrs.secondStep
      $scope.$parent.$watch $parse($attrs.secondStep), (value) ->
        secondStep = parseInt(value, 10)
        return
    # 12H / 24H mode
    $scope.showMeridian = syTimepickerConfig.showMeridian
    if $attrs.showMeridian
      $scope.$parent.$watch $parse($attrs.showMeridian), (value) ->
        $scope.showMeridian = ! !value
        if ngModelCtrl.$error.time
          # Evaluate from template
          hours = getHoursFromTemplate()
          minutes = getMinutesFromTemplate()
          if angular.isDefined(hours) and angular.isDefined(minutes)
            selected.setHours hours
            refresh()
        else
          updateTemplate()
        return
    # Respond on mousewheel spin

    @setupMousewheelEvents = (hoursInputEl, minutesInputEl, secondsInputEl) ->

      isScrollingUp = (e) ->
        if e.originalEvent
          e = e.originalEvent
        #pick correct delta variable depending on event
        delta = if e.wheelDelta then e.wheelDelta else -e.deltaY
        e.detail or delta > 0

      hoursInputEl.bind 'mousewheel wheel', (e) ->
        $scope.$apply if isScrollingUp(e) then $scope.incrementHours() else $scope.decrementHours()
        e.preventDefault()
        return
      minutesInputEl.bind 'mousewheel wheel', (e) ->
        $scope.$apply if isScrollingUp(e) then $scope.incrementMinutes() else $scope.decrementMinutes()
        e.preventDefault()
        return
      secondsInputEl.bind 'mousewheel wheel', (e) ->
        $scope.$apply if isScrollingUp(e) then $scope.incrementSeconds() else $scope.decrementSeconds()
        e.preventDefault()
        return
      return

    @setupInputEvents = (hoursInputEl, minutesInputEl, secondsInputEl) ->
      if $scope.readonlyInput
        $scope.updateHours = angular.noop
        $scope.updateMinutes = angular.noop
        $scope.updateSeconds = angular.noop
        return

      invalidate = (invalidHours, invalidMinutes, invalidSeconds) ->
        ngModelCtrl.$setViewValue null
        ngModelCtrl.$setValidity 'time', false
        if angular.isDefined(invalidHours)
          $scope.invalidHours = invalidHours
        if angular.isDefined(invalidMinutes)
          $scope.invalidMinutes = invalidMinutes
        if angular.isDefined(invalidSeconds)
          $scope.invalidSeconds = invalidSeconds
        return

      $scope.updateHours = ->
        hours = getHoursFromTemplate()
        if angular.isDefined(hours)
          selected.setHours hours
          refresh 'h'
        else
          invalidate true
        return

      hoursInputEl.bind 'blur', (e) ->
        if !$scope.validHours and $scope.hours < 10
          $scope.$apply ->
            $scope.hours = pad($scope.hours)
            return
        return

      $scope.updateMinutes = ->
        minutes = getMinutesFromTemplate()
        if angular.isDefined(minutes)
          selected.setMinutes minutes
          refresh 'm'
        else
          invalidate undefined, true
        return

      minutesInputEl.bind 'blur', (e) ->
        if !$scope.invalidMinutes and $scope.minutes < 10
          $scope.$apply ->
            $scope.minutes = pad($scope.minutes)
            return
        return

      $scope.updateSeconds = ->
        seconds = getSecondsFromTemplate()
        if angular.isDefined(seconds)
          selected.setSeconds seconds
          refresh 's'
        else
          invalidate undefined, true
        return

      secondsInputEl.bind 'blur', (e) ->
        if !$scope.invalidSeconds and $scope.seconds < 10
          $scope.$apply ->
            $scope.seconds = pad($scope.seconds)
            return
        return
      return

    @render = ->
      date = if ngModelCtrl.$modelValue then new Date(ngModelCtrl.$modelValue) else null
      if isNaN(date)
        ngModelCtrl.$setValidity 'time', false
        $log.error 'syTimepicker directive: "ng-model" value must be a Date object, a number of milliseconds since 01.01.1970 or a string representing an RFC2822 or ISO 8601 date.'
      else
        if date
          selected = date
        makeValid()
        updateTemplate()
      return

    $scope.incrementHours = ->
      addMinutes hourStep * 60
      return

    $scope.decrementHours = ->
      addMinutes -hourStep * 60
      return

    $scope.incrementMinutes = ->
      addMinutes minuteStep
      return

    $scope.decrementMinutes = ->
      addMinutes -minuteStep
      return

    $scope.incrementSeconds = ->
      addSeconds secondStep
      return

    $scope.decrementSeconds = ->
      addSeconds -secondStep
      return

    $scope.toggleMeridian = ->
      addMinutes 12 * 60 * (if selected.getHours() < 12 then 1 else -1)
      return

    return
]).directive('syTimepicker', ->
  {
    restrict: 'EA'
    require: [
      'syTimepicker'
      '?^ngModel'
    ]
    controller: 'syTimepickerCtrl'
    replace: true
    scope: {}
    templateUrl: 'syTimepicker/timepicker.html'
    link: (sscope, element, attrs, ctrls) ->
      syTimepickerCtrl = ctrls[0]
      ngModel = ctrls[1]
      if ngModel
        syTimepickerCtrl.init ngModel, element.find('input')
      return

  }
).constant('syTimepickerPopupConfig',
  timeFormat: 'HH:mm:ss'
  appendToBody: false).directive('syTimepickerPopup', [
  '$compile'
  '$parse'
  '$document'
  '$position'
  'dateFilter'
  'syTimepickerPopupConfig'
  'syTimepickerConfig'
  ($compile, $parse, $document, $position, dateFilter, syTimepickerPopupConfig, syTimepickerConfig) ->
    {
      restrict: 'EA'
      require: 'ngModel'
      priority: 1
      link: (originalScope, element, attrs, ngModel) ->
        scope = originalScope.$new()
        timeFormat = undefined
        appendToBody = if angular.isDefined(attrs.syTimepickerAppendToBody) then originalScope.$eval(attrs.syTimepickerAppendToBody) else syTimepickerPopupConfig.appendToBody
        # Initial state

        setOpen = (value) ->
          if setIsOpen
            setIsOpen originalScope, ! !value
          else
            scope.isOpen = ! !value
          return

        parseTime = (viewValue) ->
          if !viewValue
            ngModel.$setValidity 'time', true
            null
          else if angular.isDate(viewValue)
            ngModel.$setValidity 'time', true
            viewValue
          else if angular.isString(viewValue)
            date = new moment('1970-01-01 ' + viewValue, 'YYYY-MM-DD ' + timeFormat)
            if !date.isValid()
              ngModel.$setValidity 'time', false
              undefined
            else
              ngModel.$setValidity 'time', true
              date.toDate()
          else
            ngModel.$setValidity 'time', false
            undefined

        addWatchableAttribute = (attribute, scopeProperty, syTimepickerAttribute) ->
          if attribute
            originalScope.$watch $parse(attribute), (value) ->
              scope[scopeProperty] = value
              return
            syTimepickerEl.attr syTimepickerAttribute or scopeProperty, scopeProperty
          return

        updatePosition = ->
          scope.position = if appendToBody then $position.offset(element) else $position.position(element)
          scope.position.top = scope.position.top + element.prop('offsetHeight')
          return

        attrs.$observe 'syTimepickerPopup', (value) ->
          timeFormat = value or syTimepickerPopupConfig.timeFormat
          ngModel.$render()
          return
        originalScope.$on '$destroy', ->
          $popup.remove()
          scope.$destroy()
          return
        getIsOpen = undefined
        setIsOpen = undefined
        if attrs.isOpen
          getIsOpen = $parse(attrs.isOpen)
          setIsOpen = getIsOpen.assign
          originalScope.$watch getIsOpen, (value) ->
            scope.isOpen = ! !value
            return
        scope.isOpen = if getIsOpen then getIsOpen(originalScope) else false

        documentClickBind = (event) ->
          if scope.isOpen and event.target != element[0]
            scope.$apply ->
              setOpen false
              return
          return

        elementFocusBind = ->
          scope.$apply ->
            setOpen true
            return
          return

        # popup element used to display calendar
        popupEl = angular.element('<div sy-timepicker-popup-wrap><div sy-timepicker></div></div>')
        popupEl.attr
          'ng-model': 'date'
          'ng-change': 'dateSelection()'
        syTimepickerEl = angular.element(popupEl.children()[0])
        syTimepickerOptions = {}
        if attrs.syTimepickerOptions
          syTimepickerOptions = originalScope.$eval(attrs.syTimepickerOptions)
          syTimepickerEl.attr angular.extend({}, syTimepickerOptions)
        ngModel.$parsers.unshift parseTime
        # Inner change

        scope.dateSelection = (dt) ->
          if angular.isDefined(dt)
            scope.date = dt
          ngModel.$setViewValue scope.date
          ngModel.$render()
          return

        element.bind 'input change keyup', ->
          scope.$apply ->
            scope.date = ngModel.$modelValue
            return
          return
        # Outter change

        ngModel.$render = ->
          date = if ngModel.$viewValue then dateFilter(ngModel.$viewValue, timeFormat) else ''
          element.val date
          scope.date = ngModel.$modelValue
          return

        if attrs.showMeridian
          syTimepickerEl.attr 'show-meridian', attrs.showMeridian
        if attrs.showSeconds
          syTimepickerEl.attr 'show-seconds', attrs.showSeconds
        documentBindingInitialized = false
        elementFocusInitialized = false
        scope.$watch 'isOpen', (value) ->
          if value
            updatePosition()
            $document.bind 'click', documentClickBind
            if elementFocusInitialized
              element.unbind 'focus', elementFocusBind
            element[0].focus()
            documentBindingInitialized = true
          else
            if documentBindingInitialized
              $document.unbind 'click', documentClickBind
            element.bind 'focus', elementFocusBind
            elementFocusInitialized = true
          if setIsOpen
            setIsOpen originalScope, value
          return
        $popup = $compile(popupEl)(scope)
        if appendToBody
          $document.find('body').append $popup
        else
          element.after $popup
        return

    }
]).directive 'syTimepickerPopupWrap', ->
  {
    restrict: 'EA'
    replace: true
    transclude: true
    templateUrl: 'syTimepicker/popup.html'
    link: (scope, element, attrs) ->
      element.bind 'click', (event) ->
        event.preventDefault()
        event.stopPropagation()
        return
      return

  }
  