# this needs to be done first before any templates are evaluated
require ["underscore"], (_) ->
  # use {{ template delimiters }}
  _.templateSettings  =
    evaluate    : /\{{([\s\S]+?)\}\}/g
    interpolate : /\{\{=([\s\S]+?)\}\}/g
    escape      : /\{\{-([\s\S]+?)\}\}/g

define ["backbone"
  "cs!app/router/router",
  "cs!app/event/appdispatch",
  "cs!app/view/itembagview",
  "cs!app/collection/itembag",
  "cs!app/view/attachmentview",
  "cs!app/view/categorytreeview",
  "cs!app/collection/categorybag",
  "module",
  ],
  (Backbone, Router, AppDispatch,
    ItemBagView, ItemBag,
    AttachmentView,
    CategoryTreeView, CategoryBag
    module) ->
    # Router is a singleton
    class app
      constructor: ->
        collection = new ItemBag [],
          url: module.config().url
        # we don't load the ItemBagView first anymore
        #itembag_view = new ItemBagView
          #collection: collection
        attachmentview = new AttachmentView()

        categorybag = new CategoryBag [],
          url: module.config().category_url
        category_view = new CategoryTreeView
          collection: categorybag

        # TODO these events should be refactored
        AppDispatch.on 'item:show_attachments_by_id', (itemid) ->
          collection.once 'reset', ->
            item_model = collection.get(itemid)
            AppDispatch.trigger 'item:show_attachments', item_model
          collection.fetch { reset: true }

        AppDispatch.on 'attachment:open_attachment_by_id', (itemid, itemattachmentid) ->
          collection.once 'reset', ->
            attachment_bag = collection.get(itemid).attachment_bag()
            attachment_bag.once 'reset', ->
              AppDispatch.trigger('attachment:open_attachment', attachment_bag.get(itemattachmentid))
            attachment_bag.fetch { reset: true }
          collection.fetch { reset: true }

        AppDispatch.on 'item:show_attachments', (item_model) ->
          attachment_bag = item_model.attachment_bag()
          attachment_bag.once 'reset', ->
            if attachment_bag.length == 1 # if there is only one attachment_bag, open it
              AppDispatch.trigger('attachment:open_attachment', attachment_bag.at(0))
            else
              # TODO display a dialog to choose the attachment
          # build AttachmentBag collection
          attachment_bag.fetch { reset: true }

        AppDispatch.on 'attachment:open_attachment', (attachment_model) ->
          # retrieve the file and display it
          attachmentview.model = attachment_model
          attachmentview.render()

        Backbone.history.start({pushState: true})
        Router.navigate module.config().push_state,
          trigger: true
          replace: true
