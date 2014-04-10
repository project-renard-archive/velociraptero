# cs!app/model/attachment
app = app || {}
define [ "backbone" ], (Backbone) ->
  class app.Attachment extends Backbone.Model
    defaults:
      itemid: ''
      title: ''
      mimetype: ''
      attachmentid: ''
      item_attachment_file_url: ''
      item_attachment_cover_url: ''

    sync: ->
      # NOP: we'll have no syncing here
