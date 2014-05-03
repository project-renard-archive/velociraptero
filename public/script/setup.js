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
    "datatables-plugin": { deps: ["datatables", "bootstrap"] },
    "bootstrap": { deps: ["jquery"] },
    "jplayer.playlist": { deps: ["jplayer"] },
    "jquery.scrollTo" : {
      deps: ["jquery"]
    },
  },
  packages: [
    { name: 'jquery', main: 'jquery' },
    { name: 'underscore', main: 'underscore' },
    { name: 'backbone', main: 'backbone' },
    { name: 'bootstrap', main: 'bootstrap' },
    { name: 'cs', location: 'require-cs', main: 'cs' },
    { name: 'coffee-script', main: 'index' },
    { name: 'jqtree', main: 'tree.jquery.js' },
    { name: 'datatables', location: 'DataTables', main: 'jquery.dataTables.js' },
    { name: 'datatables-plugins' },
    { name: 'jplayer', main: 'jquery.jplayer.js' },
    { name: 'jplayer.playlist', location: 'jplayer', main: 'jplayer.playlist.js' },
    { name: 'findAndReplaceDOMText', main: 'findAndReplaceDOMText' },
    { name: 'jquery.scrollTo', main: 'jquery.scrollTo' },
  ]
});

require( [ "cs!app/app" ], function(app) {
  new app();
});
