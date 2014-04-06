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
  "cs!app/collection/attachmentbag",
  "cs!app/view/categorytreeview",
  "cs!app/collection/categorybag",
  "cs!app/view/itembagtable",
  "module",
  ],
  (Backbone, Router, AppDispatch,
    ItemBagView, ItemBag,
    AttachmentView, AttachmentBag
    CategoryTreeView, CategoryBag,
    ItemBagTable,
    module) ->
    # Router is a singleton
    class app
      constructor: ->
        collection = new ItemBag [],
          url: ''
          #url: module.config().url
        attachmentview = new AttachmentView()

        categorybag = new CategoryBag [],
          url: module.config().category_url

        # TODO these events should be refactored
        AppDispatch.on 'item:show_attachments_by_id', (itemid) ->
          attachment_bag = new AttachmentBag [],
            url: "/api/item/#{ itemid }/attachment"
          attachment_bag.once 'reset', ->
            AppDispatch.trigger 'item:show_attachments', attachment_bag
          attachment_bag.fetch { reset: true }

        AppDispatch.on 'attachment:open_attachment_by_id', (itemid, itemattachmentid) ->
          attachment_bag = new AttachmentBag [],
            url: "/api/item/#{ itemid }/attachment"
          attachment_bag.once 'reset', ->
            AppDispatch.trigger('attachment:open_attachment', attachment_bag.get(itemattachmentid))
          attachment_bag.fetch { reset: true }

        oApp = @
        AppDispatch.on 'item:show_attachments', (attachment_bag) ->
          console.log attachment_bag
          if attachment_bag.length == 1 # if there is only one attachment_bag, open it
            attachment_url = Router. item_attachment_file_url( attachment_bag.at(0) )
            console.log attachment_url
            oApp.newTab(attachment_url)
            window.open(attachment_url, '_blank')
            # Like running the following, but in new window / tab
            # AppDispatch.trigger('attachment:open_attachment', attachment_bag.at(0) )
          else
            # NOP
            # TODO display a dialog to choose the attachment

        AppDispatch.on 'attachment:open_attachment', (attachment_model) ->
          # retrieve the file and display it
          attachmentview.model = attachment_model
          attachmentview.render()

        AppDispatch.on 'category:show_category', (category_node) ->
          collection.url = category_node.url
          collection.datatable_url = category_node.datatable_url
          collection.id = category_node.id
          collection.reset()

        AppDispatch.on 'item:select', (datatable_row) ->
          attachment_bag = new AttachmentBag [],
            url: datatable_row.attachments_url
          attachment_bag.once 'reset', ->
            AppDispatch.trigger 'item:show_attachments', attachment_bag
          attachment_bag.fetch { reset: true }

        AppDispatch.on 'view:index', () ->
          unless(module.config().push_state)
            $("#category").addClass("col-md-2 col-lg-2")
            $("#item-data").addClass("col-md-10 col-lg-10")
            category_view = new CategoryTreeView
              collection: categorybag
            itembagtable_view = new ItemBagTable
              collection: collection

        Backbone.history.start({pushState: true})
        Router.navigate module.config().push_state,
          trigger: true
          replace: true

      newTab: (url) ->
        form = document.createElement("form")
        form.setAttribute("action",url)
        form.setAttribute("method","GET")
        form.setAttribute("target","_blank")
        document.body.appendChild(form)
        form.submit()
        document.body.removeChild(form)
