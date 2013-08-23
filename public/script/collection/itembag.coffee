# cs!app/collection/itembag
app = app || {}
define [ "backbone", "cs!app/model/item" ], (Backbone, Item) ->
  class app.ItemBag extends Backbone.Collection
      model: Item
      url: '' # must be passed in
