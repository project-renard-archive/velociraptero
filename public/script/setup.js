require.config({
  baseUrl: '../vendor',
  paths: {
    "app": '../script',
    "datatables": '../vendor/DataTables/jquery.dataTables',
    "datatables-plugins": '../vendor/datatables-plugins'
  },
  shim: {
    underscore: { exports: '_' },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    },
    "datatables-plugin": { deps: ["datatables"] },
  },
  packages: [
    { name: 'jquery', main: 'jquery' },
    { name: 'underscore', main: 'underscore' },
    { name: 'backbone', main: 'backbone' },
    { name: 'cs', location: 'require-cs', main: 'cs' },
    { name: 'coffee-script', main: 'index' },
    { name: 'jqtree', main: 'tree.jquery.js' },
    { name: 'datatables', location: 'DataTables', main: 'jquery.dataTables.js' },
    { name: 'datatables-plugins' }
  ]
});

require( [ "cs!app/app" ], function(app) {
  new app();
});
