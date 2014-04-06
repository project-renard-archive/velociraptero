# cs!app/view/categorytreeview
# c.f. cs!app/model/category
app = app || {}
define [ "backbone", "jqtree",
  "cs!app/event/appdispatch" ], (Backbone, jqtree, AppDispatch) ->
  class app.CategoryTreeView extends Backbone.View
    el: '#category-tree'
    events:
      'tree.click': 'open_category'

    initialize: () ->
      @render()

    render: ->
      $(@el).tree
        dataUrl: @collection.url
        slide: false
        dataFilter: (data) ->
          data[0]
        autoOpen: 1 # open one level
      @

    open_category: (e) ->
      AppDispatch.trigger('category:show_category', e.node)

