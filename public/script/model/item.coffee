app = app || {}
define [ "backbone" ], (Backbone) ->
  class app.Item extends Backbone.Model
    defaults:
      cover: ''
      title: ''
      author: ''
      item_attachment_url: '' # create from model id
