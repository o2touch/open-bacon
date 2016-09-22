# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20160922201825) do

  create_table "active_campaign_events", :force => true do |t|
    t.string   "email"
    t.string   "user_id"
    t.string   "contact_id"
    t.string   "event"
    t.string   "list_id"
    t.string   "campaign_id"
    t.string   "ip"
    t.string   "meta_data"
    t.datetime "event_time"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "activity_item_comments", :force => true do |t|
    t.integer  "activity_item_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "activity_item_comments", ["activity_item_id"], :name => "index_activity_item_comments_on_activity_item_id"
  add_index "activity_item_comments", ["user_id"], :name => "user_id"

  create_table "activity_item_likes", :force => true do |t|
    t.integer  "activity_item_id"
    t.integer  "user_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "activity_item_likes", ["activity_item_id"], :name => "index_activity_item_likes_on_activity_item_id"
  add_index "activity_item_likes", ["user_id"], :name => "user_id"

  create_table "activity_item_links", :force => true do |t|
    t.integer  "activity_item_id"
    t.integer  "feed_owner_id"
    t.string   "feed_owner_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "feed_type"
  end

  add_index "activity_item_links", ["activity_item_id"], :name => "activity_item_id"

  create_table "activity_items", :force => true do |t|
    t.string   "subj_type"
    t.integer  "subj_id"
    t.string   "verb"
    t.string   "obj_type"
    t.integer  "obj_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "expired"
    t.text     "meta_data"
  end

  create_table "albums", :force => true do |t|
    t.string   "cover_image_uid"
    t.string   "cover_image_name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "app_events", :force => true do |t|
    t.string   "subj_type"
    t.integer  "subj_id"
    t.string   "obj_type"
    t.integer  "obj_id"
    t.string   "verb"
    t.text     "meta_data"
    t.datetime "processed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "app_events", ["obj_id"], :name => "obj_id"
  add_index "app_events", ["subj_id"], :name => "subj_id"

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.string   "name"
    t.string   "link"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authorizations", ["user_id"], :name => "user_id"

  create_table "claim_profile_campaign_emails", :force => true do |t|
    t.string   "profile_id"
    t.string   "email_id"
    t.string   "campaign_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "email_type"
    t.string   "follow_up",   :default => "N"
  end

  create_table "club_marketing_data", :force => true do |t|
    t.string   "strategy"
    t.string   "split"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.datetime "reply_at"
    t.string   "contact_name"
    t.string   "contact_position"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.string   "twitter"
    t.string   "junior"
    t.text     "team_contacts"
    t.text     "extra"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "club_marketing_events", :force => true do |t|
    t.integer  "club_marketing_data_id"
    t.string   "event_type"
    t.integer  "email_id"
    t.datetime "date"
    t.text     "data"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "clubs", :force => true do |t|
    t.string   "name"
    t.integer  "location_id"
    t.integer  "team_profile_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "slug"
    t.integer  "faft_id"
    t.integer  "club_marketing_data_id"
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.integer  "tenant_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "message_id"
    t.integer  "user_id"
    t.string   "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "comments", ["message_id"], :name => "message_id"

  create_table "contact_requests", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "organisation"
    t.integer  "demo"
    t.text     "message"
    t.string   "data"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "mobile"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "division_seasons", :force => true do |t|
    t.string   "title"
    t.integer  "rank"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "age_group"
    t.integer  "league_id"
    t.integer  "edit_mode"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "launched",                   :default => false
    t.datetime "launched_at"
    t.string   "scoring_system"
    t.text     "points_categories"
    t.boolean  "track_results",              :default => false
    t.boolean  "show_standings",             :default => false
    t.string   "season_name"
    t.boolean  "current_season",             :default => true
    t.integer  "source_id"
    t.boolean  "competition"
    t.string   "source"
    t.string   "slug"
    t.integer  "done"
    t.integer  "tenant_id"
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.integer  "fixed_division_id"
    t.string   "tag"
  end

  add_index "division_seasons", ["source_id"], :name => "index_divisions_on_source_id"

  create_table "email_campaign_sents", :force => true do |t|
    t.string   "email_campaign_id"
    t.string   "email"
    t.string   "template_id"
    t.string   "data"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "email_campaigns", :force => true do |t|
    t.string   "campaign_id"
    t.string   "campaign_type"
    t.string   "subject_a"
    t.string   "template_a"
    t.string   "subject_b"
    t.string   "template_b"
    t.string   "layout_template"
    t.string   "from"
    t.string   "recipient_strategy_class_type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "email_notifications", :force => true do |t|
    t.integer  "notification_item_id"
    t.integer  "sender_id"
    t.string   "mailer"
    t.string   "email_type"
    t.datetime "delivered_at"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  create_table "event_messages", :force => true do |t|
    t.text     "text"
    t.integer  "user_id"
    t.integer  "messageable_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "messageable_type"
    t.text     "meta_data"
    t.string   "sent_as_role_type"
    t.integer  "sent_as_role_id"
  end

  add_index "event_messages", ["messageable_id"], :name => "event_id"

  create_table "event_reminders_queue_items", :force => true do |t|
    t.integer  "event_id"
    t.date     "scheduled_time"
    t.string   "token"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "event_reminders_queue_items", ["event_id"], :name => "event_id"

  create_table "event_results", :force => true do |t|
    t.string   "score_for"
    t.string   "score_against"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "event_id"
  end

  add_index "event_results", ["event_id"], :name => "event_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.datetime "time"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "user_id"
    t.integer  "response_by"
    t.integer  "game_type"
    t.integer  "team_id"
    t.string   "open_invite_link"
    t.integer  "invite_type"
    t.integer  "status"
    t.integer  "result_id"
    t.integer  "reminder_updated"
    t.string   "type"
    t.datetime "last_edited"
    t.boolean  "response_required", :default => true
    t.string   "time_zone"
    t.integer  "location_id"
    t.boolean  "time_tbc",          :default => false
    t.integer  "tenant_id"
    t.text     "tenanted_attrs"
  end

  add_index "events", ["team_id"], :name => "team_id"
  add_index "events", ["user_id"], :name => "user_id"

  create_table "features", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fixed_divisions", :force => true do |t|
    t.integer  "league_id"
    t.integer  "current_division_season_id"
    t.integer  "rank"
    t.string   "source"
    t.integer  "source_id"
    t.integer  "tenant_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag"
  end

  create_table "fixtures", :force => true do |t|
    t.string   "title"
    t.integer  "status"
    t.datetime "time"
    t.string   "time_zone"
    t.integer  "division_season_id"
    t.integer  "location_id"
    t.integer  "home_event_id"
    t.integer  "away_event_id"
    t.integer  "home_team_id"
    t.integer  "away_team_id"
    t.boolean  "edited"
    t.text     "edits"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "time_tbc"
    t.integer  "result_id"
    t.integer  "points_id"
    t.integer  "source_id"
    t.boolean  "competition"
    t.string   "source"
    t.datetime "trashed_at"
    t.integer  "tenant_id"
    t.string   "tag"
  end

  add_index "fixtures", ["away_event_id"], :name => "away_event_id"
  add_index "fixtures", ["away_team_id"], :name => "index_fixtures_on_away_team_id"
  add_index "fixtures", ["division_season_id"], :name => "index_fixtures_on_division_id"
  add_index "fixtures", ["home_event_id"], :name => "home_event_id"
  add_index "fixtures", ["home_team_id"], :name => "index_fixtures_on_home_team_id"
  add_index "fixtures", ["points_id"], :name => "points_id"
  add_index "fixtures", ["result_id"], :name => "index_fixtures_on_result_id"
  add_index "fixtures", ["source", "source_id"], :name => "source", :unique => true
  add_index "fixtures", ["source_id"], :name => "source_id"

  create_table "invite_reminders", :force => true do |t|
    t.integer  "teamsheet_entry_id"
    t.integer  "user_sent_by_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "invite_reminders", ["teamsheet_entry_id"], :name => "teamsheet_entry_id"

  create_table "invite_responses", :force => true do |t|
    t.integer  "teamsheet_entry_id"
    t.integer  "response_status"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "created_by_id"
  end

  add_index "invite_responses", ["teamsheet_entry_id"], :name => "teamsheet_entry_id"

  create_table "league_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "league_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "leagues", :force => true do |t|
    t.string   "title"
    t.string   "sport"
    t.string   "region"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.string   "colour1"
    t.string   "colour2"
    t.string   "cover_image_file_name"
    t.string   "cover_image_content_type"
    t.integer  "cover_image_file_size"
    t.datetime "cover_image_updated_at"
    t.text     "settings"
    t.string   "slug"
    t.string   "time_zone"
    t.integer  "source_id"
    t.string   "source"
    t.integer  "tenant_id"
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.integer  "location_id"
    t.boolean  "claimed",                    :default => false
    t.datetime "claimed_date"
    t.string   "tag"
  end

  add_index "leagues", ["slug"], :name => "index_leagues_on_slug", :unique => true
  add_index "leagues", ["source", "source_id"], :name => "source", :unique => true

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.string   "address"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
  end

  add_index "locations", ["title"], :name => "index_locations_on_title"

  create_table "mobile_apps", :force => true do |t|
    t.string "name"
    t.string "token"
  end

  create_table "mobile_devices", :force => true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "active"
    t.boolean  "logged_in"
    t.string   "platform"
    t.string   "model"
    t.string   "os_version"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "app_version"
    t.integer  "mobile_app_id"
  end

  add_index "mobile_devices", ["user_id"], :name => "user_id"

  create_table "notification_items", :force => true do |t|
    t.string   "subj_type"
    t.integer  "subj_id"
    t.string   "verb"
    t.string   "obj_type"
    t.integer  "obj_id"
    t.datetime "processed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "meta_data"
  end

  create_table "notification_receipts", :force => true do |t|
    t.integer  "notification_id"
    t.string   "notification_type"
    t.integer  "recipient_id"
    t.datetime "delivered_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "ns2_notification_items", :force => true do |t|
    t.string   "type"
    t.integer  "app_event_id"
    t.integer  "user_id"
    t.string   "medium"
    t.string   "datum"
    t.text     "meta_data"
    t.integer  "timeout"
    t.datetime "processed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "status"
    t.integer  "attempts"
    t.text     "ers"
    t.integer  "tenant_id"
  end

  add_index "ns2_notification_items", ["app_event_id"], :name => "app_event_id"
  add_index "ns2_notification_items", ["status"], :name => "status"
  add_index "ns2_notification_items", ["type"], :name => "type"
  add_index "ns2_notification_items", ["user_id"], :name => "user_id"

  create_table "open_graph_events", :force => true do |t|
    t.string   "fbid"
    t.string   "event_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "open_graph_events", ["event_id"], :name => "event_id"

  create_table "open_graph_play_ins", :force => true do |t|
    t.string   "fbid"
    t.string   "teamsheet_entry_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "open_graph_play_ins", ["teamsheet_entry_id"], :name => "teamsheet_entry_id"

  create_table "points", :force => true do |t|
    t.text     "home_points"
    t.text     "away_points"
    t.string   "strategy"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "trashed_at"
  end

  create_table "points_adjustments", :force => true do |t|
    t.integer  "division_season_id"
    t.integer  "team_id"
    t.integer  "adjustment"
    t.text     "desc"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "adjustment_type"
    t.string   "source"
    t.integer  "source_id"
  end

  create_table "poly_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "obj_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "obj_type"
    t.datetime "trashed_at"
  end

  add_index "poly_roles", ["obj_id"], :name => "team_id"
  add_index "poly_roles", ["user_id", "obj_id"], :name => "index_team_roles_on_user_id_and_team_id"
  add_index "poly_roles", ["user_id"], :name => "index_team_roles_on_user_id"
  add_index "poly_roles", ["user_id"], :name => "user_id"

  create_table "power_tokens", :force => true do |t|
    t.string   "token"
    t.string   "route"
    t.datetime "expires_at"
    t.boolean  "disabled",   :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "user_id"
  end

  add_index "power_tokens", ["route"], :name => "route"
  add_index "power_tokens", ["token"], :name => "token", :unique => true
  add_index "power_tokens", ["user_id", "disabled"], :name => "user_id"

  create_table "relations", :force => true do |t|
    t.string  "type"
    t.integer "start_v_id"
    t.string  "start_v_type"
    t.integer "end_v_id"
    t.string  "end_v_type"
  end

  create_table "results", :force => true do |t|
    t.text     "home_score"
    t.text     "away_score"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "trashed_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  add_index "roles_users", ["role_id"], :name => "role_id"
  add_index "roles_users", ["user_id"], :name => "user_id"

  create_table "scraped_contacts", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.string   "contact_link"
    t.string   "position"
    t.string   "address"
    t.string   "org_type"
    t.integer  "org_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "sendgrid_email_events", :force => true do |t|
    t.string   "email_notification_id"
    t.string   "email"
    t.string   "smtpid"
    t.string   "event"
    t.string   "category"
    t.string   "meta_data"
    t.datetime "event_time"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "sms_replies", :force => true do |t|
    t.string   "number"
    t.string   "content"
    t.integer  "teamsheet_entry_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "sms_replies", ["teamsheet_entry_id"], :name => "teamsheet_entry_id"

  create_table "sms_sents", :force => true do |t|
    t.string   "from"
    t.integer  "user_id"
    t.string   "to"
    t.string   "content"
    t.integer  "sms_reply_code"
    t.integer  "sms_reply_id"
    t.integer  "teamsheet_entry_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "app_event_id"
  end

  add_index "sms_sents", ["teamsheet_entry_id"], :name => "teamsheet_entry_id"

  create_table "team_division_season_roles", :force => true do |t|
    t.integer  "division_season_id"
    t.integer  "team_id"
    t.integer  "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag"
    t.string   "source"
    t.integer  "source_id"
  end

  add_index "team_division_season_roles", ["division_season_id"], :name => "index_divisions_teams_on_division_id"
  add_index "team_division_season_roles", ["team_id"], :name => "index_divisions_teams_on_team_id"

  create_table "team_invites", :force => true do |t|
    t.integer  "sent_by_id"
    t.integer  "sent_to_id"
    t.integer  "team_id"
    t.string   "source"
    t.datetime "accepted_at"
    t.string   "token"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "team_invites", ["team_id"], :name => "team_id"

  create_table "team_profiles", :force => true do |t|
    t.string   "sport"
    t.string   "league_name"
    t.string   "colour1"
    t.string   "colour2"
    t.integer  "age_group"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.boolean  "profile_picture_processing"
  end

  add_index "team_profiles", ["profile_picture_file_name"], :name => "profile_picture_file_name"

  create_table "team_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "team_roles", ["team_id"], :name => "team_id"
  add_index "team_roles", ["user_id", "team_id"], :name => "index_team_roles_on_user_id_and_team_id"
  add_index "team_roles", ["user_id"], :name => "index_team_roles_on_user_id"

  create_table "team_roles_activity", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "removed_at"
  end

  create_table "teams", :force => true do |t|
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "created_by_id"
    t.string   "sport"
    t.string   "name"
    t.string   "uuid"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.integer  "profile_id"
    t.string   "type"
    t.integer  "demo_mode",                    :default => 0
    t.datetime "schedule_last_sent"
    t.string   "created_by_type"
    t.text     "settings"
    t.integer  "source_id"
    t.integer  "club_id"
    t.boolean  "club_verified"
    t.string   "source"
    t.string   "slug"
    t.integer  "tenant_id"
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.string   "tag"
  end

  add_index "teams", ["profile_id"], :name => "profile_id"
  add_index "teams", ["slug"], :name => "index_teams_on_slug"
  add_index "teams", ["source", "source_id"], :name => "source", :unique => true
  add_index "teams", ["source_id"], :name => "index_teams_on_source_id"

  create_table "teamsheet_entries", :force => true do |t|
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "event_id"
    t.string   "phone_number"
    t.integer  "user_id"
    t.string   "token"
    t.boolean  "invite_sent",            :default => false
    t.integer  "invite_responses_count", :default => 0,     :null => false
    t.boolean  "checked_in",             :default => false
    t.datetime "checked_in_at"
  end

  add_index "teamsheet_entries", ["event_id"], :name => "event_id_ix"
  add_index "teamsheet_entries", ["token"], :name => "index_teamsheet_entries_on_token", :unique => true
  add_index "teamsheet_entries", ["user_id"], :name => "index_teamsheet_entries_on_user_id"

  create_table "tenants", :force => true do |t|
    t.string   "name"
    t.string   "subdomain"
    t.string   "logo"
    t.text     "settings"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.string   "i18n"
    t.boolean  "sms"
    t.boolean  "email"
    t.string   "colour_1"
    t.string   "colour_2"
    t.integer  "mobile_app_id"
  end

  create_table "unclaimed_league_profiles", :force => true do |t|
    t.string   "name"
    t.string   "sport"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug"
  end

  create_table "unclaimed_team_profile_problems", :force => true do |t|
    t.integer  "unclaimed_team_profile_id"
    t.string   "problem_type"
    t.string   "additional_info"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "unclaimed_team_profiles", :force => true do |t|
    t.string   "name"
    t.integer  "team_id"
    t.string   "location"
    t.string   "league_name"
    t.string   "season",          :limit => 20
    t.string   "contact_name"
    t.string   "contact_number"
    t.string   "contact_email"
    t.string   "slug"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
    t.string   "token"
    t.string   "sport"
    t.string   "contact_name2"
    t.string   "contact_number2"
    t.string   "contact_email2"
    t.string   "contact_title2"
    t.string   "contact_title"
    t.string   "colour1"
    t.string   "colour2"
    t.string   "source",                        :default => "UNKNOWN"
  end

  create_table "user_follow_team_tests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "faft_division_season_id"
    t.integer  "faft_team_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.datetime "imported_at"
    t.datetime "followed_at"
    t.string   "error"
  end

  create_table "user_full_contact_details", :force => true do |t|
    t.string   "email"
    t.string   "photo_url"
    t.string   "full_contact_json"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "user_invitation_responses", :force => true do |t|
    t.string   "response"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.string   "bio"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string   "gender"
    t.date     "dob"
    t.integer  "location_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                      :default => ""
    t.string   "encrypted_password",         :default => ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "name"
    t.string   "lazy_id"
    t.string   "time_zone"
    t.string   "mobile_number"
    t.string   "username"
    t.integer  "invited_by_source_user_id"
    t.string   "invited_by_source"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "country"
    t.text     "settings"
    t.integer  "profile_id"
    t.string   "profile_picture_uid"
    t.integer  "bluefields_invite_id"
    t.string   "type"
    t.date     "dob"
    t.integer  "parent_id"
    t.integer  "children_count",             :default => 0
    t.string   "incoming_email_token"
    t.integer  "tenant_id"
    t.text     "tenanted_attrs"
    t.text     "configurable_settings_hash"
    t.string   "configurable_parent_type"
    t.integer  "configurable_parent_id"
    t.boolean  "unsubscribe"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "email"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["time_zone"], :name => "time_zone"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "users_from_beta", :primary_key => "uid", :force => true do |t|
    t.string  "name",             :limit => 60,         :default => "", :null => false
    t.string  "pass",             :limit => 32,         :default => "", :null => false
    t.string  "mail",             :limit => 320,        :default => ""
    t.integer "mode",             :limit => 1,          :default => 0,  :null => false
    t.integer "sort",             :limit => 1,          :default => 0
    t.integer "threshold",        :limit => 1,          :default => 0
    t.string  "theme",                                  :default => "", :null => false
    t.string  "signature",                              :default => "", :null => false
    t.integer "signature_format", :limit => 2,          :default => 0,  :null => false
    t.integer "created",                                :default => 0,  :null => false
    t.integer "access",                                 :default => 0,  :null => false
    t.integer "login",                                  :default => 0,  :null => false
    t.integer "status",           :limit => 1,          :default => 0,  :null => false
    t.string  "timezone",         :limit => 8
    t.string  "language",         :limit => 12,         :default => "", :null => false
    t.string  "picture",                                :default => "", :null => false
    t.string  "init",             :limit => 64,         :default => ""
    t.text    "data",             :limit => 2147483647
    t.string  "timezone_name",    :limit => 50,         :default => "", :null => false
  end

  add_index "users_from_beta", ["access"], :name => "access"
  add_index "users_from_beta", ["created"], :name => "created"
  add_index "users_from_beta", ["mail"], :name => "mail", :length => {"mail"=>255}
  add_index "users_from_beta", ["name"], :name => "name", :unique => true

  create_table "users_teams_notification_settings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "team_id"
    t.string   "notification_key"
    t.boolean  "value"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "users_teams_notification_settings", ["team_id"], :name => "team_id"
  add_index "users_teams_notification_settings", ["user_id"], :name => "user_id"

  create_table "users_unsubscribed", :force => true do |t|
    t.integer  "user_id"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "utm_data", :force => true do |t|
    t.text     "referer"
    t.string   "source"
    t.string   "medium"
    t.string   "term"
    t.string   "content"
    t.string   "campaign"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "utm_data", ["user_id"], :name => "index_utm_data_on_user_id"

  create_table "vanity_conversions", :force => true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], :name => "by_experiment_id_and_alternative"

  create_table "vanity_experiments", :force => true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], :name => "index_vanity_experiments_on_experiment_id"

  create_table "vanity_metric_values", :force => true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], :name => "index_vanity_metric_values_on_vanity_metric_id"

  create_table "vanity_metrics", :force => true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], :name => "index_vanity_metrics_on_metric_id"

  create_table "vanity_participants", :force => true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], :name => "by_experiment_id_and_converted"
  add_index "vanity_participants", ["experiment_id", "identity"], :name => "by_experiment_id_and_identity"
  add_index "vanity_participants", ["experiment_id", "seen"], :name => "by_experiment_id_and_seen"
  add_index "vanity_participants", ["experiment_id", "shown"], :name => "by_experiment_id_and_shown"
  add_index "vanity_participants", ["experiment_id"], :name => "index_vanity_participants_on_experiment_id"

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "modifications"
    t.integer  "number"
    t.integer  "reverted_from"
    t.string   "tag"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

end
