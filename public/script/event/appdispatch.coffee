# cs!app/event/appdispatch
# singleton
app = app || {}
define [ "backbone" ], (Backbone) ->
  # just a clone
  new _.clone( Backbone.Events ) # return an instance
