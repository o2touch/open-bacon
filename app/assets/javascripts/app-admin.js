// ##### 
// 
// APP-ADMIN
// This is used in the 'app_admin' and 'league_reporting' layout.
// 
// #####
//
//
// LIBRARY HELPERS
//= require_tree ./backbone/helpers
//
// BACKBONE
//= require modernizr/modernizr
//= require jquery/jquery
//= require underscore/underscore
//= require backbone/backbone
//= require backbone-relational/backbone-relational
//= require marionette/lib/backbone.marionette.js
//
// APP FILES
//= require ./backbone/app_files/App
//= require ./backbone/app_files_standalone/TenantAdminApp
//
// CONTROLLERS
//= require ./backbone/controllers/TenantAdmin
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
//= require backbone/views/common/NaviView
//
// MODELS
//= require ./backbone/models/ActivityItemObject
//= require ./backbone/models/Club
//= require ./backbone/models/Division
//= require ./backbone/models/Fixture
//= require ./backbone/models/League
//= require ./backbone/models/LeagueRole
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
//= require webarch
//= require reports/reports
//= require reports/refactored_reports