# cs!app/view/attachmentview
# c.f. cs!app/model/attachment
app = app || {}
define [ "backbone", "module" ], (Backbone, module) ->
  class app.AttachmentView extends Backbone.View
    el: '#doc'
    template: _.template( $( '#attachment-template' ).html() ),
    #model : '' # this gets passed in
    viewer_url: module.config().viewer_url

    render: ->
      $(@el).html @template(@model.toJSON())
      @
