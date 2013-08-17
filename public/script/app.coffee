# this needs to be done first before any templates are evaluated
require ["underscore"], (_) ->
  # use {{ template delimiters }}
  _.templateSettings.interpolate = /\{\{(.+?)\}\}/g
  _.templateSettings.escape = /\{\{-(.*?)\}\}/g

define ["backbone"
  "cs!app/view/itembagview",
  "cs!app/collection/itembag",
  "module",
  ],
  (Backbone, ItemBagView, ItemBag, module) ->
    class app
      constructor: ->
        collection = new ItemBag [],
          url: module.config().url
        new ItemBagView
          collection: collection
