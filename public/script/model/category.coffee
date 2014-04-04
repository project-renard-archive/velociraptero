# cs!app/model/category
app = app || {}
define [ "backbone" ], (Backbone) ->
  class app.Category extends Backbone.Model
    defaults:
      name: ''
      children: []
