$rollout = Rollout.new($redis, :migrate => true)

#  FEATURES
#  :faft_follow_team - turns on proper following for Unclaimed Team/Division pages
#  :download_app - turns on prompts to download the app

# $rollout.activate_group(:chat, :all)
# $rollout.activate_user(:chat, @user)
# $rollout.deactivate_group(:chat, :all)
