# cs!app/view/itemview
# c.f. cs!app/model/item
app = app || {}

define [ "backbone", "cs!app/event/appdispatch" ],
(Backbone, AppDispatch) ->
  class app.ItemView extends Backbone.View
    tagName: 'li'
    className: 'item nav-pill'
    template: _.template( $( '#item-template' ).html() ),
    #model : '' # this gets passed in
    events:
      'click': 'open_attachments'

    render: ->
      $(@el).html @template(@model.toJSON())
      @

    open_attachments: (e) ->
      e.preventDefault()
      AppDispatch.trigger('item:show_attachments', @model)
