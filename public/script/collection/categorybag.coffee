# cs!app/collection/categorybag
app = app || {}
define [ "backbone", "cs!app/model/category" ], (Backbone, Category) ->
  class app.CategoryBag extends Backbone.Collection
      model: Category
      url: '' # must be passed in
