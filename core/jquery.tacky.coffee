# ----------------------------------------------------------------------
#  Project: jQuery.Tacky
#  Description: Sticky menu with changing active element
#  Author: Scott Elwood
#  Maintained By: We the Media, inc.
#  License: MIT
#
#  Version: 1.0
# ----------------------------------------------------------------------

(($, window, document, undefined_) ->
  pluginName = 'tacky'

  defaults = 
    itemSelector: 'a'
    parentSelector: null

    tackedClass: 'tacked'
    activeClass: 'active'
    toggleClass: 'toggle'
    openClass: 'open'
    
    floating: false
    scrollSpeed: 500
    scrollEasing: ''
    closeMenuWidth: 700
    markerOffset: .4

  Plugin = (element, options) ->
    @options = $.extend({}, defaults, options)

    @$nav = $(element)
    @$toggle_button = @$nav.find("." + @options.toggleClass)
    @options.itemSelector += '[href^="#"]'

    @init()

    # In case of elements loading slowly, initialize again
    setTimeout (=> @init()), 500

  Plugin:: =
    init: ->
      @_getDOMProperties()
      @_getPositions()
      @_createEvents()

    _getDOMProperties: ->
      @_getElementSizes()
      @_getNavOrigin()

    _getElementSizes: ->
      @document_height = $(document).height()
      @window_height = $(window).height()
      @marker_offset = @window_height * @options.markerOffset
      @nav_height = @$nav.height()

    _getNavOrigin: ->
      tackedClass = @options.tackedClass

      if @$nav.hasClass(tackedClass)
        @$clone.hide() if @$clone
        @$nav.removeClass(tackedClass)
        @nav_origin = @$nav.offset().top
        @$nav.addClass(tackedClass)
        @$clone.show() if @$clone
      else
        @nav_origin = @$nav.offset().top

    _getPositions: ->
      @links = @$nav.find(@options.itemSelector)
      @targets = @links.map -> $(this).attr('href')

      @positions = []
      @targets.each (i, target) =>
        @positions.push $(target).offset().top + 1

    _createEvents: ->
      $(document).off('scroll.tacky').on "scroll.tacky", => @_scroll()
      $(window).off('scroll.tacky').on "resize.tacky", => @_resize()

      self = @
      @links.off('click.tacky').on "click.tacky", (evt, i) ->
        evt.preventDefault()
        self._scrollToTarget($(this).attr('href'))

      @$toggle_button.off('click.tacky').on 'click.tacky', => @_toggleOpen()

    _scroll: ->
      scroll_position = $(document).scrollTop()
      active_i = null

      if scroll_position > @nav_origin
        @_tackNav(true)

        nav_position = scroll_position + @nav_height
        if nav_position >= @positions[0] - 1
          marker_position = scroll_position + @marker_offset

          if scroll_position + @window_height is @document_height
            marker_position = @document_height

          for pos, i in @positions
            if marker_position >= pos
              active_i = i
      else
        @_tackNav(false)

      @_setActive(active_i) if active_i isnt null

    _tackNav: (tacked) ->
      if tacked
        if @$nav.css('position') is 'static'
          @$clone = @$nav.clone(false).insertBefore(@$nav).css({ visibility: 0 })

        @$nav.addClass(@options.tackedClass)
      else
        @_clearActive()
        @$clone.remove() if @$clone
        @$nav.removeClass(@options.tackedClass)

    _setActive: (i) ->
      if i isnt @active_i
        @_clearActive()

        @active_i = i
        $active_item = @links.eq(i)
        parentSelector = @options.parentSelector

        if parentSelector
          $active_item.closest(parentSelector).addClass(@options.activeClass)
        else
          $active_item.addClass(@options.activeClass)

    _clearActive: ->
      @active_i = null
      active_class = @options.activeClass
      @$nav.find('.'+active_class).removeClass(active_class)

    _resize: ->
      @_getDOMProperties() # Recalculate
      @_getPositions() # Recalculate
      @_scroll() # Trigger reset
      @_detoggle()

    _scrollToTarget: (target_id) ->
      position_index = $.inArray(target_id, @targets)
      position = @positions[position_index]
      position -= @nav_height unless @options.floating

      scroll_speed = if @$nav.hasClass(@options.openClass) then 0 else @options.scrollSpeed

      @_scrollTo(position, scroll_speed)

      openClass = @options.openClass
      @$nav.removeClass(openClass) if @$nav.hasClass(openClass)
      
    _scrollTo: (position, speed) ->
      $("html, body").stop().animate({scrollTop: position}, speed, @options.scrollEasing)

    _toggleOpen: ->
      openClass = @options.openClass
      tackedClass = @options.tackedClass

      if @$nav.hasClass(openClass)
        @$nav.removeClass(openClass)
      else
        @$nav.addClass(openClass)
        
    _detoggle: ->
      closeMenuWidth = @options.closeMenuWidth

      if closeMenuWidth >= 0
        document_width = $(document).width()

        if document_width >= closeMenuWidth
          @$nav.removeClass(@options.openClass)

    destroy: ->
      $(document).off('scroll.tacky')
      $(window).off('scroll.tacky')
      @links.off('click.tacky')
      @$toggle_button.off('click.tacky')


  # ----------------------------------------------------------------------
  # ------------------------ Dirty Initialization ------------------------
  # ----------------------------------------------------------------------
  $.fn[pluginName] = (options) ->
    args = arguments
    scoped_name = "plugin_" + pluginName
    
    if options is `undefined` or typeof options is "object"
      # Initialization
      @each ->
        unless $.data(@, scoped_name)
          $.data @, scoped_name, new Plugin(@, options)

    else if typeof options is "string" and options[0] isnt "_" and options isnt "init"
      # Calling public methods
      returns = undefined
      @each ->
        instance = $.data(@, scoped_name)

        if instance instanceof Plugin and typeof instance[options] is "function"
          returns = instance[options].apply(instance, Array::slice.call(args, 1))

        $.data @, scoped_name, null  if options is "destroy"
      (if returns isnt `undefined` then returns else @)
) jQuery, window, document