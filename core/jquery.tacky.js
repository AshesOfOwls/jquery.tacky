// Generated by CoffeeScript 1.4.0
(function() {

  (function($, window, document, undefined_) {
    var Plugin, defaults, pluginName;
    pluginName = 'tacky';
    defaults = {
      tackedClass: 'tacked',
      itemSelector: 'a',
      parentSelector: null,
      activeClass: 'active',
      scrollSpeed: 500
    };
    Plugin = function(element, options) {
      var _this = this;
      this.options = $.extend({}, defaults, options);
      this.$nav = $(element);
      this.init();
      return setTimeout((function() {
        return _this.init();
      }), 500);
    };
    Plugin.prototype = {
      init: function() {
        this.setGlobals();
        this.getTargets();
        this.createEvents();
        return this.getPositions();
      },
      setGlobals: function() {
        this.document_height = $(document).height();
        this.window_height = $(window).height();
        this.nav_height = this.$nav.outerHeight();
        if (!this.$nav.hasClass(this.options.tackedClass)) {
          return this.nav_position = this.$nav.offset().top;
        }
      },
      createEvents: function() {
        var nav_height, scroll_speed,
          _this = this;
        $(document).on("scroll.tacky", function() {
          return _this.scroll();
        });
        $(window).on("resize.tacky", function() {
          _this.setGlobals();
          return _this.scroll();
        });
        nav_height = this.nav_height;
        scroll_speed = this.options.scrollSpeed;
        return this.links.on("click", function(evt) {
          var $target, position, target_id;
          evt.preventDefault();
          target_id = $(this).attr('href');
          $target = $(target_id);
          position = $target.offset().top - nav_height + 1;
          return $("html, body").animate({
            scrollTop: position
          }, scroll_speed);
        });
      },
      getTargets: function() {
        var item_selector;
        item_selector = this.options.itemSelector;
        this.links = this.$nav.find(item_selector);
        return this.targets = this.links.map(function() {
          return $(this).attr('href');
        });
      },
      getPositions: function() {
        var _this = this;
        this.positions = [];
        return this.targets.each(function(i, target) {
          var position;
          position = $(target).offset().top;
          return _this.positions.push(position);
        });
      },
      scroll: function() {
        var active_i, i, pos, scroll_mid_position, scroll_nav_position, scroll_percent, scroll_position, scroll_total, _i, _len, _ref;
        scroll_position = $(document).scrollTop();
        scroll_nav_position = $(document).scrollTop() + this.nav_height;
        scroll_mid_position = scroll_position + (this.window_height / 2);
        if (scroll_position > this.nav_position) {
          this.toggleNav(true);
          if (scroll_nav_position > this.positions[0]) {
            scroll_total = this.document_height - this.window_height;
            scroll_percent = scroll_position / scroll_total;
            if (scroll_percent > .99) {
              scroll_mid_position += this.window_height;
            }
            active_i = null;
            _ref = this.positions;
            for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
              pos = _ref[i];
              if (scroll_mid_position > pos) {
                active_i = i;
              }
            }
            return this.setActive(active_i);
          } else {
            return this.clearActive();
          }
        } else {
          return this.toggleNav(false);
        }
      },
      toggleNav: function(stick) {
        if (stick) {
          return this.$nav.addClass(this.options.tackedClass);
        } else {
          this.$nav.removeClass(this.options.tackedClass);
          return this.clearActive();
        }
      },
      setActive: function(i) {
        var $active_item, active_class;
        this.clearActive();
        if (i >= 0) {
          active_class = this.options.activeClass;
          $active_item = this.links.eq(i);
          return $active_item.parent().addClass(active_class);
        }
      },
      clearActive: function() {
        var active_class;
        active_class = this.options.activeClass;
        return this.$nav.find('.' + active_class).removeClass(active_class);
      }
    };
    return $.fn[pluginName] = function(options) {
      var args, returns, scoped_name;
      args = arguments;
      scoped_name = "plugin_" + pluginName;
      if (options === undefined || typeof options === "object") {
        return this.each(function() {
          if (!$.data(this, scoped_name)) {
            return $.data(this, scoped_name, new Plugin(this, options));
          }
        });
      } else if (typeof options === "string" && options[0] !== "_" && options !== "init") {
        returns = void 0;
        this.each(function() {
          var instance;
          instance = $.data(this, scoped_name);
          if (instance instanceof Plugin && typeof instance[options] === "function") {
            returns = instance[options].apply(instance, Array.prototype.slice.call(args, 1));
          }
          if (options === "destroy") {
            return $.data(this, scoped_name, null);
          }
        });
        if (returns !== undefined) {
          return returns;
        } else {
          return this;
        }
      }
    };
  })(jQuery, window, document);

}).call(this);
