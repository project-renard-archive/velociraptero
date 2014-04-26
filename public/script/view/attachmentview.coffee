# cs!app/view/attachmentview
# c.f. cs!app/model/attachment
app = app || {}
define [ "backbone", "module", "jplayer" ], (Backbone, module) ->
  class app.AttachmentView extends Backbone.View
    el: '#doc'
    player: '#jquery_jplayer_1'
    template: _.template( $( '#attachment-template' ).html() ),
    #model : '' # this gets passed in
    viewer_url: module.config().viewer_url

    render: ->
      $(@el).html @template(@model.toJSON())
      $(@player).jPlayer
        supplied: 'mp3'
      $(@player).jPlayer "setMedia",
        mp3: '/api/phrase'
      $(@player).jPlayer "play"
      @
