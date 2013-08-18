app = app || {}
define [ "backbone" ], (Backbone) ->
  Backbone = require("backbone")
  class app.Item extends Backbone.Model
    defaults:
      cover: ''
      title: ''
      author: ''
