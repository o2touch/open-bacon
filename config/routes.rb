require 'sidekiq/web'

BluefieldsRails::Application.routes.draw do

  ####
  # *** Legacy shit, left in for old mobile apps.
  ######
  post 'teamsheet_entries/:tse_id/invite_responses.json' => 'api/v1/invite_responses#create'
  ###
  # End legacy shit
  ####

  get "download" => "download#download", as: "app_download"
  post "download" => "download#download"
  get "download-app" => "download#app_store_redirect", as: "app_store_download"
  post "download/send-link" => "download#send_install_link"
  get "install" => "download#app_store_redirect", as: "app_install"

  namespace :admin do
    resources :leagues
  end

  default_url_options :host => Rails.application.config.domain

  resources :events, :only => [:index,:create,:update,:show] do
    get :confirm, :on => :member
    resources :permissions, :only => [:index], :controller => "users/user_permissions"
    resources :activity_items, :only => [:index]
  end

  match 'leagues/index' => "leagues#index"
  
  # allow extra args used by front end
  get 'leagues/:id(/*args)'  => 'leagues#show', as: :league, constraints: { :id => /\d+/ }
  get 'leagues/:slug(/*args)'  => 'leagues#show', as: :league
  post 'leagues/:id/upload_image' => 'leagues#upload_image'
  # old url, now 301ed to the above
  match 'league/:league_slug' => 'leagues#show'#, :as => :unclaimed_league



  match 'teams/index' => "teams#index"
  resources :teams, :only => [:index, :show, :create, :update] do
    resources :events
    post :upload_profile_picture, :on => :member
    resources :invites, :only => [], :controller => "team_invites" do
      put :confirm, :on => :member
    end
  end
  get 'teams/:team_id/user_preference' => 'user_preference#show', :as => :team_user_preference
  match 'league/:league_slug/:division_slug/:team_slug' => 'teams#show', :as => :league_team 

  # DEPRECATED - FAFT Team routes
  # Still used for Supporting old mobile app versions and links from search
  match 'division/:faft_ds_id/team/:faft_team_id' => 'teams#show'

  # Divisions
  match 'league/:league_slug/:division_slug' => 'division_seasons#show', :as => :division
  match 'divisions/index' => "division_seasons#index"
  match 'divisions/:id' => 'division_seasons#show', :as => :division_normal
  

  resources :event_schedule, :only => [:create], :controller => "event_schedule"

  resources :users, :only => [:index, :show,:update], :controller => "users/user_profiles", :as => :user do
    post :upload_profile_picture, :on => :member
  end
  
  resources :activity_items, :only => [:index]
  resources :activity_item_comments, :only => [:create]
  
  # Devise Routes
  devise_for :users, :path_prefix => 'd',  :controllers => { 
    :registrations => "users/registrations", 
    :omniauth_callbacks => "users/omniauth_callbacks",
    :sessions => "users/sessions"
  }
  #resources :user_registrations, :only => [:create], :controller => "users/user_registrations"
  put 'user_registrations' => 'users/user_registrations#create'
  post 'user_registrations' => 'users/user_registrations#create'
  devise_scope :user do
    get "/signup(/:invite_code)" => "users/registrations#new", as: :signup
    get "/login" => "users/sessions#new"
    get "/logout" => "devise/sessions#destroy"
    delete "/logout" => "devise/sessions#destroy"
  end
  get 'unsubscribe' => 'users/unsubscribe#show'
      
  # Facebook App
  namespace :facebook do
    match 'home' => 'test#index'
    match '' => 'facebook#index'
  end

  # TENANTS
  # widgets etc. 
  get 'tenants/o2_touch/search' => 'tenants/o2_touch#search'

  # reports
  get 'tenants/:tenant_name/reports'  => 'tenants/reports#show'
  get 'tenants/:tenant_name/refactored_reports'  => 'tenants/refactored_reports#show'
  get 'tenants/:tenant_name/reports/participation'  => 'tenants/reports#show_participation'
  get 'tenants/:tenant_name/reports/engagement'  => 'tenants/reports#show_engagement'

  # Rewards and Recognition
  get 'tenants/:tenant_name/rewards'  => 'tenants/rewards_and_recognition#show'
  get 'tenants/:tenant_name/rewards/drilldown'  => 'tenants/rewards_and_recognition#show_drilldown'
  get 'tenants/:tenant_name/rewards/attendance'  => 'tenants/rewards_and_recognition#attendance'

  # dashboard
  get 'tenants/:tenant_name'  => 'tenants/dashboard#show'
  get 'tenants/:tenant_name/dashboard' => 'tenants/dashboard#show'
  get 'tenants/:tenant_name/teams' => 'tenants/dashboard#show_teams'

  # CSV downlaods
  get 'tenants/:tenant_name/csvs/headline' => 'tenants/csv_downloads#headline'
  get 'tenants/:tenant_name/csvs/per_team' => 'tenants/csv_downloads#per_team'
  get 'tenants/:tenant_name/csvs/players' => 'tenants/csv_downloads#players'
  get 'tenants/:tenant_name/csvs/users' => 'tenants/csv_downloads#users'

  # /api/v1/<request>
  scope 'api' do
    ['v1'].each do |version|
      scope version, module: "api/#{version}" do

        get 'activity_items/mindex' => 'activity_items#mobile_index'
        get 'activity_items/show' => 'activity_items#show' #without an ID
        
        resources :activity_items, except: [:new, :edit], as: :api_v1_activity_item do
          resources :comments, controller: 'activity_item_comments', except: [:new, :edit]
          resources :likes, controller: 'activity_item_likes', :only => [:create]

          member do
            delete 'likes' => 'activity_item_likes#destroy'
          end
        end

        resources :clubs, only: [:show]

        resources :divisions, controller: 'division_seasons', only: [:show], as: :api_v1_division do
          resources :fixtures, only: [:create]
          resources :points_adjustments, only: [:create]
          member do
            post   'publish_edits' => 'division_seasons#publish_edits'
            post   'clear_edits'   => 'division_seasons#clear_edits'
            get    'standings'     => 'division_seasons#standings'
            post   'registrations' => 'division_seasons#open_registrations'
            delete 'registrations' => 'division_seasons#close_registrations'
          end
        end
        # separate as need to control names of params...
        post 'divisions/:division_id/teams' => 'teams#create'

        resources :events, except: [:new, :edit], as: :api_v1_event do
          member do
            get 'teamsheet' => "teamsheet_entries#index"
            get 'teamsheet_minified' => "teamsheet_entries#mindex"
          end
        end

        resources :fixtures, only: [:index, :show, :update, :destroy], as: :api_v1_fixture do
          resources :results, only: [:create]
          resources :points, only: [:create]
          member do
            post 'clear_edits' => 'fixtures#clear_edits'
          end
        end

        resources :invite_reminders, :only => [:show, :create]
        resources :leagues, only: [:index, :show, :create, :update], as: :api_v1_league do
          resources :fixed_divisions, only: [:create]
          resources :divisions, controller: 'division_seasons', only: [:index]
        end
        resources :locations, only: [:index], as: :api_v1_location

        resources :messages, controller: 'event_messages', except: [:new, :edit], as: :api_v1_event_message

        namespace :mail do
          resources :messages, only: [:create]
          post 'messages/bounced' => 'messages#bounced'
        end

        resources :points, only: [:update]
        resources :results, only: [:update]

        resources :team_division_season_roles, only: [:create, :update, :destroy], as: :api_v1_tdsr
        post 'division_season/:division_season_id/teams/:team_id/:role' => 'team_division_season_roles#update'

        resources :team_roles, :only => [:destroy, :create], as: :api_v1_team_role

        resources :teamsheet_entries, only: [:index], as: :api_v1_tse do
          member do
            post 'check_in' => 'check_ins#create'
            delete 'check_in' => 'check_ins#destroy'
          end
        end

        resources :teams, except: [:new, :edit], as: :api_v1_team do
          member do
            post   'send_schedule' => 'teams#send_schedule'
            post   'demo_users' => 'teams#add_demo_users'
            delete 'demo_users' => 'teams#remove_demo_users'
            post   'follow' => 'teams#follow'
            post   'send_activation_links' => 'teams#send_activation_links'
          end
          resources :events, only: [:index]
        end

        post 'translator/transaction_items' => 'translator/trans_items#create'

        post 'check_ins' => 'check_ins#bulk'

        post 'teamsheet_entries/:tse_id/invite_responses' => 'invite_responses#create'
        # create from event and user
        post 'teamsheet_entries/invite_responses' => 'invite_responses#create'
        
        # active campaign
        post 'active_campaign_callbacks/sent/:email_id' => 'active_campaign_callbacks#sent'
        post 'active_campaign_callbacks/create' => 'active_campaign_callbacks#create'

        # fa full-time shit
        get 'fa-full-time/divisions/:id' => 'fa_full_time#division'

        # search
        get 'search' => 'search#show'

        # user profiles shit
        post   'users/invitations' => 'users/user_invitations#create'
        post   'users/registrations' => 'users/user_registrations#create'
        post   'users/facebook_registrations' => 'users/facebook_registrations#create'
        put    'users/registrations' => 'users/user_registrations#create'
        get    'users/invitations/:id' => 'users/user_invitations#show', :as => 'user_invitation'

        get    'users/:id/notifications/teams/:team_id' => 'users/team_notification_settings#show', :as => 'user_team_notificiation_settings'
        put    'users/:id/notifications/teams/:team_id' => 'users/team_notification_settings#update', :as => 'user_team_notificiation_settings'
        get    'users/:id/notifications/teams' => 'users/team_notification_settings#index', :as => 'user_team_notificiation_settings'

        get    'users' => 'users/user_profiles#index'
        get    'users/:id'  => 'users/user_profiles#show'
        post   'users' => 'users/user_profiles#create'
        delete 'users/:id' => 'users/user_profiles#destroy'
        put    'users/:id' => 'users/user_profiles#update'

        get    'users/:id/events'  => 'events/#index' #user should be defined as a resource

        post   'teams/guest_create'   => 'teams#guest_create'
        put    'teams/:team_uuid/guest_update'   => 'teams#guest_update'
        post   'users/new_team_organiser' => 'users/user_registrations#new_team_organiser'

        get    'team_generation_status' => 'faft_instructions#index'

        # DEPRECATED
        # Used in mobile app versions < 1.3 when following a team
        post   'faft/teams' => 'faft_instructions#create_team'
        
        # mobile specific ting
        namespace :m do
          post   'sessions' => "sessions#create"
          delete 'sessions' => "sessions#destroy"

          get    'home-cards' => 'home_cards#index'

          # this is to return data for the mobile nav
          get    'nav' => 'nav#show'
          post   'device_registrations' => 'device_registrations#create'
          delete 'device_registrations/:token' => 'device_registrations#destroy'
        end
        
        # reports end points
        # TODO: split this up into separate controllers, and make it nicer. TS
        namespace :reports do
          get 'overview/summary' => 'reports#overview_summary'
          get 'participation/summary' => 'reports#participation_summary'
          get 'participation/gender' => 'reports#participation_split'
          get 'participation/experience' => 'reports#participation_split'
          get 'participation/source' => 'reports#participation_split'
          get 'participation/frequency' => 'reports#participation_frequency'
          get 'engagement/summary' => 'reports#engagement_summary'
          get 'users/activated' => 'reports#users_activated'
          get 'users/by_gender' => 'reports#users_by_gender'
          get 'users/by_experience' => 'reports#users_by_experience'
          get 'events/total' => 'reports#events_total'
          get 'clubs/total' => 'reports#clubs_total'
        end

        namespace :refactored_reports do
          get 'summary' => 'reports#summary'
          get 'chart' => 'reports#chart'
        end



        # Split testing routes
        get 'split/alternative/:experiment_name' => "split#get_alternative"
        post 'split/finished/:experiment_name' => "split#finish_split_experiment"
        
      end
    end
    match "*path", to: "api/v1/application#raise_routing_error"
  end
  
  namespace :hooks do
    post "sendgrid/events" => "sendgrid#events"
    post "activecampaign/actions" => "active_campaign#actions"
  end

  # BF Admin
  namespace :admin do

    get 'caches/leagues/clear_all_pages' => 'leagues#clear_all_page_caches'
    resources :leagues do
      post :upload_image
      get :add_organiser_form
      post :add_organiser
      get :send_notifications
    end    

    get 'fixtures/:faft_id' => 'fixtures#show'
    resources :index
    get 'users/active' => 'users#active'
    resources :users
    resources :events
    resources :teams do 
      match 'rtrc' => 'teams#refresh_team_roles_cache', :as => :rtrc
      match 'remove_player/:user_id' => 'teams#remove_player', :as => :remove_player
      match 'remove_organiser_role/:user_id' => 'teams#remove_organiser_role', :as => :remove_organiser_role
    end

    resources :clubs
    post 'clubs/upload' => 'clubs#upload', as: :club_upload

    resources :team_profiles
    resources :feed
    resources :email_campaigns do
      get 'preview/:template' => 'email_campaigns#preview'
      post :run
    end
    resources :claim_profile_campaign
    resources :bf_beta_invite_requests, :only => [:index] do
      post :send_invites, :on => :collection
    end
    match "newindex" => 'index#newindex'
    match "become/:id" => 'admin#become'
    match "facebook" => 'facebook#index'
    match "facebook/friendslikes" => 'facebook#friendslikes'

    # Metrics Controller
    get 'metrics' => 'metrics#index'
    get 'metrics/users/active' => 'metrics#active_users'
    get 'metrics/users/retention' => 'metrics#user_retention'
    get 'metrics/teams' => 'metrics#teams'
    get 'metrics/teams/all' => 'metrics#active_teams'
    get 'metrics/teams/junior' => 'metrics#teams_junior'
    get 'metrics/teams/leagues' => 'metrics#teams_leagues'
    get 'metrics/teams/follows' => 'metrics#teams_follows'
    get 'metrics/games' => 'metrics#game_analysis'
    get 'metrics/notifications' => 'metrics#notifications'
    get 'metrics/league' => 'metrics#league'
    get 'metrics/league/divisions/:divisions' => 'metrics#league_divisions'
    get 'metrics/features' => 'metrics#feature_usage'
    get 'metrics/faft' => 'metrics#faft'
    get 'metrics/followers' => 'metrics#followers'
    get 'metrics/user_growth' => 'metrics#user_accounting'

    # Marketing
    get 'marketing/clubs-to-tweet' => 'marketing#clubs_to_tweet'

    # Unclaimed Teams
    get 'unclaimed_team_profiles/faft' => 'unclaimed_team_profiles#faft'

    # buttons
    get 'ui' => 'admin#ui'

    # Email test Routes
    get 'email'                              => 'email_preview#index'
    get 'email/bluefields-invite'            => 'email_preview#bluefields_invite'
    get 'email/invite'                       => 'email_preview#invite'
    get 'email/schedule'                     => 'email_preview#schedule'
    get 'email/registration-confirmation'    => 'email_preview#registration_confirmation'
    # get 'email/team-invite-accepted'         => 'email_preview#team_invite_accepted'
    get 'email/event-reminder'               => 'email_preview#event_reminder'
    get 'email/event-reminder-available'     => 'email_preview#event_reminder_available'
    get 'email/event-details-updated'        => 'email_preview#event_details_updated'
    get 'email/event-cancelled'              => 'email_preview#event_cancelled'
    get 'email/event-schedule-update'        => 'email_preview#event_schedule_update'
    get 'email/event-schedule-update-single' => 'email_preview#event_schedule_update_single'
    get 'email/invite-reminder'              => 'email_preview#invite_reminder'
    get 'email/contact-form'                 => 'email_preview#contact_form'
    get 'email/response-notification'        => 'email_preview#invite_response_notification'
    get 'email/beta-invite'                  => 'email_preview#beta_invite'
    get 'email/new-user-invited'             => 'email_preview#new_user_invited_to_team'
    get 'email/result-created'               => 'email_preview#result_created'
    get 'email/division-result-created'      => 'email_preview#division_result_created'
    
    get 'email/event-activated'                                              => 'email_preview#event_activated'    
    get 'email/organiser-role-revoked-from-user'                             => 'email_preview#organiser_role_revoked_from_user'
    get 'email/organiser-role-granted-to-user'                               => 'email_preview#organiser_role_granted_to_user'
    get 'email/user-removed-from-team'                                       => 'email_preview#user_removed_from_team'
    get 'email/team-organiser-notification-new-user-invited-to-team'         => 'email_preview#team_organiser_notification__new_user_invited_to_team'
    get 'email/team-organiser-notification-organiser-role-revoked-from-user' => 'email_preview#team_organiser_notification__organiser_role_revoked_from_user'
    get 'email/team-organiser-notification-organiser-role-granted-to-user'   => 'email_preview#team_organiser_notification__organiser_role_granted_to_user'
    get 'email/team-organiser-notification-user-removed-from-team'           => 'email_preview#team_organiser_notification__user_removed_from_team'
    get 'email/team-organiser-notification-new-user-invited-to-team'         => 'email_preview#team_organiser_notification__new_user_invited_to_team'

    get 'email/league/user_invited_to_team' => 'email_preview#league_user_invited_to_team'
    get 'email/league/organiser_role_granted_to_user' => 'email_preview#league_organiser_role_granted_to_user'
    get 'email/league/event_schedule' => 'email_preview#league_event_schedule'

    get 'email/comment-from-email-failure' => 'email_preview#comment_from_email_failure'

    if Rails.env.development?
      mount MailPreview => 'mail_view'
      mount FollowerMailPreview => 'follower_mail_view'
    end
    
    get 'email/team_message_posted' => 'email_preview#team_message_posted'
    
  end  
  
  resources :home  

  constraint = lambda { |request| request.env["warden"].authenticate? and request.env['warden'].user.role?(RoleEnum::ADMIN) }
  constraints constraint do
    mount Sidekiq::Web, at: '/sidekiq'
  end

  # Split Dashboard
  match "admin/split" => Split::Dashboard, :anchor => false, :constraints => lambda { |request|
    request.env['warden'].authenticated? # are we authenticated?
    request.env['warden'].authenticate! # authenticate if not already
    # request.env['warden'].user.is_admin?
  }
    
  # Standard Routes
  match 'dashboard' => 'users/user_profiles#show'
  match 'events' => 'users/user_profiles#show'
  match 'manage-availability' => "home#manage_availability"
  
  # THESE SHOULDN'T BE NEEDED ANY MORE
  match 'register_guest_user' => 'application#register_guest_user', :as => :register_guest_user
  match 'register_guest_user_player' => 'application#register_guest_user_player', :as => :register_guest_user_player
  match 'register_player' => 'application#register_player'
  match 'register_guest_user_open_invite' => 'application#register_guest_user_open_invite'
  
  # Links
  get   'nekot/:token' => 'power_tokens#show', as: :power_token
  match 'links/invite-response/:token(/:response)' => 'events#show', :as => :invite_link
  match 'links/confirm-reminders/:token' => 'event_reminders_queue#update', :as => :auto_event_reminders_confirm
  match 'links/open-invite/:open_invite_link' => 'events#show', :as => :open_invite_link
  match 'links/team-invite/:token' => 'team_invites#show', :as => :team_invite_link
  match 'g/:open_invite_link' => 'events#show', :as => :open_invite_link

  # FAFT Unclaimed Leagues
  match 'faft/leagues/index' => "unclaimed/league_profiles#index"

  # Twilio  
  match 'voice', :controller => :twilio, :action => :voice
  match 'sms-reply', :controller => :twilio, :action => :sms_reply

  # News leo's shit
  match 'default/theme'  => 'sass#show_default'
  match 'event/:id/theme'  => 'sass#show_event'
  match 'user/:id/theme'  => 'sass#show_user'
  match 'club/:id/theme'  => 'sass#show_club'
  match 'division/:id/theme'  => 'sass#show_division'
  match 'league_theme/:id/theme'  => 'sass#show_league'  
  # This was 404ing as there was no sass#show_team action, so changed to this.
  match 'team/:id/theme'  => 'sass#show_default'
  
  # Home / Search
  match 'search' => 'home#search'

  post 'contact_requests/create' => 'contact_requests#create'


  # MITOO/GOALRUN ROUTES
  # This is to maintain links pointing to old mitoo/goalrun site
  get "beta" => 'old_mitoo#handle_routes'

  # FOOTBALL MITOO ROUTES
  # This is to redirect leagues from FootballMitoo to corresponding Mitoo league
  get "fm-redirect" => 'old_mitoo#redirect_fm_leagues'


  # O2 TOUCH DEFAULT ROUTES
  # The default route goes to o2touch search
  constraints(TenantSubdomain) do
    get '' => 'tenants/o2_touch#landing_page'
    get 'login' => 'users/sessions#new'
  end


  # You can have the root of your site routed with "root"
  root :to => 'home#search'
  
  # Install the non-vanity user profile route above the vanity route so people
  # who don't have shortenable logins can still have a URL to their profile page.
  match 'users/:id', :controller => 'users/user_profiles', :action => 'show', :conditions => { :method => :get }, :as => :long_profile
  # Install the vanity user profile route above the default routes but below all
  # resources.
  match ':username', :controller => 'users/user_profiles', :action => 'show', :conditions => { :method => :get }, :as => :short_profile # TODO add constraints around this route

end
