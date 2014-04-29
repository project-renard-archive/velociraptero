# cs!app/model/attachment
app = app || {}
define [ "backbone", "cs!app/model/sentence" ], (Backbone, Sentence) ->
  class app.Attachment extends Backbone.Model
    defaults:
      itemid: ''
      title: ''
      mimetype: ''
      attachmentid: ''
      item_attachment_file_url: ''
      item_attachment_cover_url: ''
      tts_model_url: ''

    sync: ->
      # NOP: we'll have no syncing here

    get_tts_model: ->
      s = new Sentence
        tts_url: @.get 'tts_model_url'
      s.fetch()
      s

