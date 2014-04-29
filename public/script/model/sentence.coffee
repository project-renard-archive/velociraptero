# cs!app/model/sentence
app = app || {}
define [ "backbone" ], (Backbone) ->
  class app.Sentence extends Backbone.Model
    sentences: []
    playlist: []
    tts_url: ''

    url: ->
      @.get 'tts_url'
