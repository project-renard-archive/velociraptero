# cs!app/view/attachmentview
# c.f. cs!app/model/attachment
app = app || {}
define [ "backbone", "module", "jplayer.playlist" ], (Backbone, module) ->
  class app.AttachmentView extends Backbone.View
    el: '#doc'
    player: '#jquery_jplayer_1'
    player_template: _.template( $('#jplayer-pink-flag-template').html() )
    template: _.template( $( '#attachment-template' ).html() )
    #model : '' # this gets passed in
    viewer_url: module.config().viewer_url

    render: ->
      $(@el).html @template(@model.toJSON())
      $('#player').html @player_template()
      tts_model =  @model.get_tts_model()
      tts_model.fetch
        success: ->
          playlist = tts_model.get('playlist')
          myPlaylist = new jPlayerPlaylist(
            {}, # use default selectors
            playlist,
            {
              playlistOptions:
                autoPlay: true
              supplied: 'mp3'
              keyEnabled: true
            })
          myPlaylist.displayPlaylist()
          myPlaylist.play()
      @
