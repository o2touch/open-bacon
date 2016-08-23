# config valid only for Capistrano 3.1
lock '3.3.5'

set :application, 'mitoo-bacon'
set :application_host, 'mitoo.co'
set :repo_url, 'git@github.com:Bluefieldscom/bacon.git'

# Set roles
set :sidekiq_role, :sidekiq

# Assets Roles
# By default assets are only precompiled on :web. We need this for our sidekiq server
set :assets_roles, [:web, :app]

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/mitoo-bacon'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/redis-cache.yml config/redis-store.yml config/initializers/keen.rb}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Deployment Notification Settings
set :hipchat_token, "fa9246d778a9061123567a5fa7b35b"
set :hipchat_room_name, "Commentary Box"
set :hipchat_announce, true # notify users?

# rbenv configuration
set :rbenv_path, '/opt/rbenv'
set :rbenv_type, :system
# TODO: Remove need for rbenv_ruby setting
set :rbenv_ruby, '1.9.3-p551' # This needs to match the system ruby set in ./cookbooks/mitoo-steak-staging/recipes/default.rb
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all

set :user, 'deploy'
set :unicorn_config_path, '/etc/unicorn/mitoo-bacon.rb'

namespace :deploy do

  desc 'Restart application'
  after :restart, :restart_passenger do
    on roles(:web, :app), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :touch, 'tmp/restart.txt'
      end
    end
  end

  after :finishing, 'deploy:restart_passenger'
  after :publishing, :restart


  # Upload compiled assets
  # after :finished, :asset_sync do
  #   on roles :web do
  #     execute "echo Running asset sync"
  #     within release_path do
  #       system "RAILS_ENV=#{fetch(:stage)} RAILS_GROUPS=assets bundle exec rake assets:sync --trace"
  #     end
  #   end
  # end

  # Restart Onyx
  #after :restart_passenger, "onyx:restart"

end

# NEW RELIC
# Send notice of deployment to New Relic
after "deploy:updated", "newrelic:notice_deployment"

# CRONTAB/WHENEVER
# Update the whenever crontab
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }
set :whenever_roles,        ->{ :db }
set :whenever_command,      ->{ [:bundle, :exec, :whenever] }
set :whenever_command_environment_variables, ->{ {} }
set :whenever_environment,  ->{ fetch :rails_env, "production" }
set :whenever_variables,    ->{ "environment=#{fetch :whenever_environment}" }
set :whenever_update_flags, ->{ "--update-crontab #{fetch :whenever_identifier} --set #{fetch :whenever_variables}" }
set :whenever_clear_flags,  ->{ "--clear-crontab #{fetch :whenever_identifier}" }
require "whenever/capistrano"

# Get git
def current_git_commit
  git_commit = `git rev-parse --short HEAD`.strip
end

# Oh... pretty colours
def red(str)
  "\e[31m#{str}\e[0m"
end