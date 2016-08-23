// ##### 
// 
// APP-EVENT-SEARCH
// This is used for the RFU iframe ting
// 
// #####
//
// BACKBONE
//= require modernizr/modernizr
//= require jquery/jquery
//= require underscore/underscore
//= require backbone/backbone
//= require backbone-live/backbone-live
//= require backbone-relational/backbone-relational
//= require marionette/lib/backbone.marionette.js
//
// PLUGINS
//= require agolia/dist/algoliasearch.min.js
//= require jquery-easing/jquery.easing.1.3.min
//= require spin.js/spin
//= require spinjs-jquery/jquery.spin
//= require moment/moment
//
// BLUEFIELDS CODE (order matters)
//
// APP FILES
//= require ./backbone/app_files/App
//= require ./backbone/app_files_standalone/MapSearchApp
//
// CONTROLLERS
//= require ./backbone/controllers/MapSearch
//
// TEMPLATES
//= require_tree ./backbone/templates/map_search
//= require ./backbone/templates/common/content/event_row
//= require ./backbone/templates/common/content/map
//
// VIEWS (order matters)
//= require ./backbone/views/common/content/EventRow
//= require ./backbone/extendable_views/Map
//= require ./backbone/views/common/content/map/LocationEditMap
//= require_tree ./backbone/views/map_search
//
// MODELS
//= require ./backbone/models/ActivityItemObject
//= require ./backbone/models/Division
//= require ./backbone/models/Event
//= require ./backbone/models/League
//= require ./backbone/models/Team
//= require ./backbone/models/User
//= require ./backbone/models/Location
//= require ./backbone/models/TeamsheetEntry
//
// COLLECTIONS
//= require ./backbone/zcollections/Events
//= require ./backbone/zcollections/Divisions
//= require ./backbone/zcollections/Leagues
//= require ./backbone/zcollections/TeamsheetEntries
//
// MISC
//= require ./misc/misc
//= require ./misc/pluginPresets
//= require ./misc/constants
//= require ./misc/validation