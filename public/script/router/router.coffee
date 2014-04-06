# cs!app/router/router
# singleton
app = app || {}
define [ "backbone", "cs!app/event/appdispatch" ], (Backbone, AppDispatch) ->
  class app.Router extends Backbone.Router
    routes:
      '': 'index'
      'item/:itemid/attachment': 'item_attachments'
      'item/:itemid/attachment/:itemattachmentid': 'item_attachment_file'
      'item/:itemid/attachment/:itemattachmentid/#name': 'item_attachment_file'

    initialize: ->
      AppDispatch.on 'item:open_attachments', (item_model) =>
        @navigate @item_attachments_url(item_model)
      AppDispatch.on 'attachment:open_attachment', (attachment_model) =>
        @navigate @item_attachment_file_url(attachment_model)

    index: () ->
      AppDispatch.trigger 'view:index'

    item_attachments: (itemid) ->
      AppDispatch.trigger 'item:show_attachments_by_id', itemid

    item_attachment_file: (itemid, itemattachmentid) ->
      AppDispatch.trigger 'attachment:open_attachment_by_id', itemid, itemattachmentid

    # return the Backbone route for opening the attachments
    item_attachments_url: (item) ->
      '/item/' + item.attributes.id + '/attachment'

    # return the Backbone route for the attachment
    item_attachment_file_url: (attachment) ->
      '/item/' + attachment.attributes.itemid + '/attachment/' + attachment.id

  new app.Router() # return an instance
