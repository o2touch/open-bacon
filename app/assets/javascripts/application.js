// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
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
//= require jquery.ui/ui/jquery.ui.effect
//= require tipsy/src/javascripts/jquery.tipsy
//= require jquery.cookie/jquery.cookie
//= require glDatePicker/glDatePicker
//= require jquery-resize/jquery.ba-resize.min
//= require jquery-easing/jquery.easing.1.3.min
//= require jquery-file-upload/js/vendor/jquery.ui.widget
//= require jquery-file-upload/js/jquery.iframe-transport
//= require jquery-file-upload/js/jquery.fileupload
//= require jquery-file-upload/js/jquery.fileupload-process
//= require jquery-file-upload/js/jquery.fileupload-validate
//= require HTML5-Progress-polyfill/progress-polyfill
//= require spin.js/spin
//= require spinjs-jquery/jquery.spin
//= require jquery-autosize/jquery.autosize
//= require jquery-placeholder/jquery.placeholder.min
//= require jquery-ujs/src/rails
//= require owl-carousel/owl.carousel.min
//= require pusher/pusher-2.1.6-min
//= require intl-tel-input/build/js/intlTelInput
//= require moment/moment
//= require math.uuid/Math.uuid
//
// LIBRARY HELPERS
//= require_tree ./backbone/helpers
//
// BLUEFIELDS CODE (order matters)
//= require_tree ./backbone/_backbone_extensions
//= require_tree ./backbone/_marionette
//= require_tree ./backbone/app_files
//= require_tree ./backbone/extendable_controllers
//= require_tree ./backbone/controllers
//= require_tree ./backbone/models
//= require_tree ./backbone/routers
//= require_tree ./backbone/templates
//= require_tree ./backbone/extendable_views
//= require_tree ./backbone/item_views
//= require_tree ./backbone/views
//= require_tree ./backbone/zcollections
//= require_tree ./misc