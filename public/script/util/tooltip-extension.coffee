# cs!app/util/tooltip-extension
#  # already loaded
define [ "jquery", "bootstrap" ], ($) ->
  # from <http://stackoverflow.com/questions/14694930/callback-function-after-tooltip-popover-is-created-with-twitter-bootstrap>
  tmp = $.fn.tooltip.Constructor.prototype.show
  $.fn.tooltip.Constructor.prototype.show = () ->
    tmp.call(this)
    if this.options.callback
      this.options.callback()
