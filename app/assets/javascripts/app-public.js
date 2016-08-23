// ##### 
// 
// APP-PUBLIC
// This is used in the 'app_public' layout. It should only inlude the required files for
// the public team, league, and division pages.
// 
// #####
//
// BACKBONE
//= require modernizr/modernizr
//= require jquery/jquery
//= require underscore/underscore
//= require backbone/backbone
//= require backbone-relational/backbone-relational
//= require marionette/lib/backbone.marionette.js
//
// PLUGINS
//= require agolia/dist/algoliasearch.min.js
//= require jquery.cookie/jquery.cookie
//= require jquery-easing/jquery.easing.1.3.min
// needed for goal widget
//= require HTML5-Progress-polyfill/progress-polyfill
//= require spin.js/spin
//= require spinjs-jquery/jquery.spin
//= require jquery-placeholder/jquery.placeholder.min
//= require intl-tel-input/build/js/intlTelInput
//= require jquery-file-upload/js/vendor/jquery.ui.widget
//= require jquery-file-upload/js/jquery.iframe-transport
//= require jquery-file-upload/js/jquery.fileupload
//= require jquery-file-upload/js/jquery.fileupload-process
//= require jquery-file-upload/js/jquery.fileupload-validate
//= require moment/moment
//= require math.uuid/Math.uuid
//
// BLUEFIELDS CODE (order matters)
//
// LIBRARY HELPERS
//= require_tree ./backbone/helpers
//
// APP FILES
//= require ./backbone/app_files/App
//= require ./backbone/app_files/ABFApp
//= require ./backbone/app_files/BFApp.Popup
//= require ./backbone/app_files/BFApp.Godbar
//= require ./backbone/app_files/BFApp.FaftProfile
//= require ./backbone/app_files/SearchApp
//
// CONTROLLERS
//= require ./backbone/controllers/App
//= require ./backbone/controllers/FaftProfile
//= require ./backbone/controllers/Godbar
//= require ./backbone/controllers/Popup
//= require ./backbone/controllers/Search
//
// TEMPLATES
//= require_tree ./backbone/templates/common
//= require_tree ./backbone/templates/faft
//= require_tree ./backbone/templates/godbar
//= require_tree ./backbone/templates/partials
//= require ./backbone/templates/panels/panel_layout
//= require ./backbone/templates/panels/o2_touch/o2_touch_team_marketing_panel
//= require ./backbone/templates/panels/club_panel
//= require ./backbone/templates/profiles/user/content/team_form/mitoo_fields
//= require_tree ./backbone/templates/popups
//= require_tree ./backbone/templates/profiles/team/unclaimed
//= require_tree ./backbone/templates/search
//= require_tree ./backbone/templates/panels/user_details
//
// VIEWS
//= require_tree ./backbone/extendable_views
//= require_tree ./backbone/views/common
//= require_tree ./backbone/views/faft
//= require_tree ./backbone/views/godbar
//= require ./backbone/views/panels/PanelLayout
//= require ./backbone/views/panels/ClubPanel
//= require ./backbone/views/panels/o2_touch/O2TouchTeamMarketingPanel
//= require_tree ./backbone/views/popup
//= require_tree ./backbone/views/profiles/team/unclaimed
//= require_tree ./backbone/item_views/search
//= require_tree ./backbone/views/search
//= require_tree ./backbone/views/panels/user_details
//
// MODELS
//= require ./backbone/models/ActivityItemObject
//= require ./backbone/models/Club
//= require ./backbone/models/Division
//= require ./backbone/models/Fixture
//= require ./backbone/models/League
//= require ./backbone/models/LeagueRole
//= require ./backbone/models/Location
//= require ./backbone/models/Result
//= require ./backbone/models/Team
//= require ./backbone/models/TeamRole
//= require ./backbone/models/User
//
// COLLECTIONS
//= require ./backbone/zcollections/Divisions
//= require ./backbone/zcollections/Fixtures
//= require ./backbone/zcollections/Leagues
//= require ./backbone/zcollections/LeagueRoles
//= require ./backbone/zcollections/Teams
//= require ./backbone/zcollections/TeamRoles
//
// MISC
//= require_tree ./misc