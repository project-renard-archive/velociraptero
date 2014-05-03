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
      regexify_text = (text) ->
        #text = text.replace /./g, '\\s*$&'
        text = text.replace /[\[\]\(\)\.\+\*\?\|]/g, '\\$&' # escape metacharacters
        text = text.replace /\s+/g, '\\s*' # turn all spaces into zero-or-more spaces
        text
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

              # if page container exists, use that, otherwise just use the top
              iframe_target = if iframe_page_container then iframe_page_container else iframe_doc


              cur_idx = myPlaylist.current
              # get text in tts_model

              # we use both the regular text and the unidecode text...
              # this fixes problems that arise from differences in pdftohtml and pdf2htmlEX
              #
              # TODO but the best fix would be to find the nodes on the server
              # side as Perl is more powerful at text analysis
              cur_text = tts_model.get('sentences')[cur_idx].text
              cur_text_unidecode = tts_model.get('sentences')[cur_idx].text_unidecode
              find_str = "#{ regexify_text(cur_text) }|#{ regexify_text(cur_text_unidecode) }"
              console.log find_str

              try
                finder = window.findAndReplaceDOMText iframe_target,
                  find: ///#{ find_str }///
                  wrap: $('<span class="highlight-tts" style="background-color: yellow; font-weight: bolder;">')[0]
                  #wrap: 'b'
                console.log finder
                console.log $(iframe_target)
                first_element = $(iframe_target).find('.highlight-tts').first()
                console.log first_element
                if( first_element )
                  $( iframe_target ).scrollTo first_element
              catch e
                true

              # show text in tooltip
              $('#tooltip-tts').text(cur_text)
      @
