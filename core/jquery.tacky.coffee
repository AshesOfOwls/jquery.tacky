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
    
    scrollSpeed: 500
    scrollEasing: ''

  Plugin = (element, options) ->
    @options = $.extend({}, defaults, options)
    @$nav = $(element)
    @$toggle_button = @$nav.find("." + @options.toggleClass)

    @init()

    # In case of elements loading slowly, initialize again
    setTimeout (=> @init()), 500

  Plugin:: =
    init: ->
      @getDOMProperties()
      @getTargets()
      @getPositions()
      @createEvents()

    # Get the heights and offsets for relevant elements
    getDOMProperties: ->
      @document_height = $(document).height()
      @window_height = $(window).height()

      # Get the navigation height
      @nav_height = @$nav.outerHeight()

      # Get the navigation position
      unless @nav_position >= 0
        tackedClass = @options.tackedClass
        if !@$nav.hasClass(tackedClass)
          @nav_position = @$nav.offset().top
        else
          @$nav.removeClass(tackedClass)
          @nav_position = @$nav.offset().top
          @$nav.addClass(tackedClass)

    # Get the links and determine the target panes from them
    getTargets: ->
      @links = @$nav.find(@options.itemSelector)
      @targets = @links.map -> $(this).attr('href')

    # Get a list of offsets for each pane
    getPositions: ->
      @positions = []

      @targets.each (i, target) =>
        @positions.push $(target).offset().top

    createEvents: ->
      # Scrolling
      $(document).on "scroll.tacky", => @scroll()

      # Resizing
      $(window).on "resize.tacky", =>
        @getDOMProperties()
        @getPositions()
        @scroll()

      self = @
      @links.off('click.tacky').on "click.tacky", (evt, i) ->
        evt.preventDefault()
        self.scrollTo($(this).attr('href'))

      @$toggle_button.off('click.tacky').on 'click.tacky', => @toggleOpen()

    toggleOpen: ->
      openClass = @options.openClass
      tackedClass = @options.tackedClass

      if @$nav.hasClass(openClass)
        @$nav.removeClass(openClass)
      else
        @$nav.addClass(openClass)

        unless @$nav.hasClass(tackedClass)
          $("html, body").stop().animate({scrollTop: @nav_position}, @options.scroll_speed, @options.scroll_easing)

    scrollTo: (target_id) ->
      position_index = $.inArray(target_id, @targets)
      position = @positions[position_index]

      if @$nav.hasClass(@options.openClass)
        $("html, body").stop().animate({scrollTop: position}, 0)
        @toggleOpen()
      else
        $("html, body").stop().animate({scrollTop: position}, @options.scroll_speed, @options.scroll_easing)

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

          @setActiveMenuItem(active_i)
        else
          @clearActiveMenuItem()
      else
        @toggleNav(false)
        
    toggleNav: (stick) ->
      if stick
        @$nav.addClass(@options.tackedClass)
      else
        @$nav.removeClass(@options.tackedClass)
        @clearActiveMenuItem()

    setActiveMenuItem: (i) ->
      @clearActiveMenuItem()

      if i >= 0
        active_class = @options.activeClass
        $active_item = @links.eq(i)
        $active_item.parent().addClass(active_class)

    clearActiveMenuItem: ->
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