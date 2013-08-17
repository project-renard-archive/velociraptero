app = app || {}
define [ "backbone",
  "cs!app/collection/itembag"
  "cs!app/view/itemview" ],
(Backbone, ItemBag, ItemView) ->
  class app.ItemBagView extends Backbone.View
    el: '#item-list'

    events: {
    }

    initialize: () ->
      @collection.fetch({ reset: true })
      @render

      @listenTo @collection, 'add', @_render_item
      @listenTo @collection, 'reset', @render

    render: ->
      @collection.each (item) =>
        @_render_item item

    _render_item: (item) ->
      scan_view = new ItemView
        model: item
      $(@el).append scan_view.render().el
