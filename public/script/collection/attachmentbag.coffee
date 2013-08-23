# cs!app/collection/attachmentbag
app = app || {}
define [ "backbone", "cs!app/model/attachment" ], (Backbone, Attachment) ->
  class app.AttachmentBag extends Backbone.Collection
      model: Attachment
      url: '' # must be passed in
