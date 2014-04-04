# cs!app/view/categorytreeview
# c.f. cs!app/model/category
app = app || {}
define [ "backbone", "jqtree" ], (Backbone, jqtree) ->
  class app.CategoryTreeView extends Backbone.View
    el: '#category-tree'

    initialize: () ->
      @render()

    render: ->
      $(@el).tree
        dataUrl: @collection.url
        slide: false
        dataFilter: (data) ->
          data[0]
      @
