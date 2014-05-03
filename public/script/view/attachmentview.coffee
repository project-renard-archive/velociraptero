# cs!app/view/attachmentview
# c.f. cs!app/model/attachment
app = app || {}
define [ "backbone", "module", "jplayer.playlist", "findAndReplaceDOMText", "jquery.scrollTo" ], (Backbone, module) ->
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
      finder = null # for findAndReplaceDOMText
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
          #myPlaylist.displayPlaylist()
          #myPlaylist.play()
          # event myPlaylist on play
          $(myPlaylist.cssSelector.jPlayer).bind $.jPlayer.event.play,
            () ->
              finder?.revert() # remove any highlighting from before

              iframe = document.getElementsByClassName('file-view')[0]
              iframe_doc = `iframe.contentDocument ?  iframe.contentDocument
                                                   : (iframe.contentWindow ? iframe.contentWindow.document : iframe.document)`
              iframe_page_container = iframe_doc.getElementById('page-container')

              cur_idx = myPlaylist.current
              # get text in tts_model
              find_str = tts_model.get('sentences')[cur_idx].text
              find_str = find_str.replace /\s+/g, '\\s*'
              console.log find_str


              finder = window.findAndReplaceDOMText iframe_page_container,
                find: ///#{ find_str }///
                wrap: $('<span class="highlight-tts" style="background-color: yellow; font-weight: bolder;">')[0]
                #wrap: 'b'
              console.log finder
              console.log $(iframe_page_container)
              first_element = $(iframe_page_container).find('.highlight-tts').first()
              console.log first_element
              if( first_element )
                $( iframe_page_container ).scrollTo first_element
      @
