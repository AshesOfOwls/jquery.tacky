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
    tackedClass: 'tacked'
    itemSelector: 'a'
    parentSelector: null
    activeClass: 'active'
    toggleClass: 'toggle'
    openClass: 'open'
    scrollSpeed: 500
    scrollEasing: ''

  Plugin = (element, options) ->
    @options = $.extend({}, defaults, options)
    @$nav = $(element)

    @init()

    # In case of elements loading slowly, initialize again
    setTimeout (=> @init()), 500

  Plugin:: =
    init: ->
      @setGlobals()
      @getTargets()
      @createEvents()
      @getPositions()

    setGlobals: ->
      @document_height = $(document).height()
      @window_height = $(window).height()
      @nav_height = @$nav.outerHeight()

      tackedClass = @options.tackedClass
      if !@$nav.hasClass(tackedClass)
        @nav_position = @$nav.offset().top
      else
        @$nav.removeClass(tackedClass)
        @nav_position = @$nav.offset().top
        @$nav.addClass(tackedClass)

    createEvents: ->
      $(document).on "scroll.tacky", => @scroll()
      $(window).on "resize.tacky", => @setGlobals(); @getPositions(); @scroll();

      nav_height = @nav_height
      scroll_speed = @options.scrollSpeed
      scroll_easing = @options.scrollEasing
      @links.on "click", (evt) ->
        evt.preventDefault()

        target_id = $(this).attr('href')
        $target = $(target_id)

        position = $target.offset().top - nav_height
        $("html, body").animate({scrollTop: position}, scroll_speed, scroll_easing)

      openClass = @options.openClass
      tackedClass = @options.tackedClass
      $toggle_button = @$nav.find("." + @options.toggleClass)
      $toggle_button.off('click.tacky').on 'click.tacky', =>
        if @$nav.hasClass(openClass)
          @$nav.removeClass(openClass)
        else
          @$nav.addClass(openClass)

          unless @$nav.hasClass(tackedClass)
            $("html, body").animate({scrollTop: @nav_position}, scroll_speed, scroll_easing)


    getTargets: ->
      item_selector = @options.itemSelector
      @links = @$nav.find(item_selector)
      @targets = @links.map -> $(this).attr('href')

    getPositions: ->
      @positions = []

      @targets.each (i, target) =>
        position = $(target).offset().top
        @positions.push position

    scroll: ->
      scroll_position = $(document).scrollTop()
      scroll_nav_position = $(document).scrollTop() + @nav_height
      scroll_mid_position = scroll_position + (@window_height / 2)
      
      if scroll_position >= @nav_position
        @toggleNav(true)

        if scroll_nav_position >= @positions[0]
          scroll_total = @document_height - @window_height
          scroll_percent = scroll_position / scroll_total

          if scroll_percent >= .99
            scroll_mid_position += @window_height

          active_i = null
          for pos, i in @positions
            if scroll_mid_position >= pos
              active_i = i

          @setActive(active_i)
        else
          @clearActive()
      else
        @toggleNav(false)
        

    toggleNav: (stick) ->
      if stick
        @$nav.addClass(@options.tackedClass)
      else
        @$nav.removeClass(@options.tackedClass)
        @clearActive()

    setActive: (i) ->
      @clearActive()

      if i >= 0
        active_class = @options.activeClass
        $active_item = @links.eq(i)
        $active_item.parent().addClass(active_class)

    clearActive: ->
      active_class = @options.activeClass
      @$nav.find('.'+active_class).removeClass(active_class)

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