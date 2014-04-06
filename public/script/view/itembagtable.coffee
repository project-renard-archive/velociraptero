# cs!app/view/itembagtable
app = app || {}
define [ "backbone",
  "cs!app/collection/itembag",
  "cs!app/event/appdispatch",
  "datatables"
],
(Backbone, ItemBag, AppDispatch) ->
  require([ "datatables-plugins/dataTables.bootstrap", "datatables-plugins/fnReloadAjax" ])
  class app.ItemBagTable extends Backbone.View
    el: '#item-data-table'

    initialize: () ->
      # add table head
      $(@el).html("""
        <thead>
          <tr>
            <th>Title</th>
            <th>Authors</th>
            <th>Year</th>
          </tr>
        </thead>""")

      # initialise DataTables to get data using AJAX
      $(@el).dataTable
          bProcessing: true
          aoColumns: [
            { "mData": "title" },
            { "mData": "authors" },
            { "mData": "date" } ]

      # use Bootstrap's .table-hover for rows
      $(@el).addClass('table-hover')
      # even-odd stripes
      $(@el).addClass('table-striped')

      # selectable rows
      table = $(@el)
      $('#item-data-table').on 'draw.dt', () ->
        $('#item-data-table tbody tr').on 'click', () ->
          $('#item-data-table tr.active').removeClass('active')
          $(this).addClass( 'active' )
          row_data = table.dataTable().fnGetData( this )
          AppDispatch.trigger( 'item:select', row_data )

      @listenTo @collection, 'reset', @render

    render: ->
      unless @collection.id == 0
        $(@el).dataTable().fnReloadAjax(@collection.datatable_url)

