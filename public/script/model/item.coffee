# cs!app/model/item
app = app || {}
define [ "backbone",
  "cs!app/collection/attachmentbag" ],
(Backbone, AttachmentBag) ->
  class app.Item extends Backbone.Model
    defaults:
      cover: ''
      title: ''
      author: ''
      attachments_url: ''

    attachment_bag: ->
      bag = new AttachmentBag [],
        url: @attributes.attachments_url

    sync: ->
      # NOP: we'll have no syncing here
