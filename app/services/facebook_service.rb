
class FacebookService
  class << self


    # Post an Organise game action for user
    def post_organise_game_action(team, user, event)

      # Don't post twice and only for U13+ teams
      if event.open_graph_event.nil? && team.profile.age_group >= 13
          
          graph = self.get_graph_object(user)
          return if graph.nil?

          fbid = graph.put_connections("me", Facebook::NAMESPACE.to_s + ":organise", "game" => Rails.application.routes.url_helpers.url_for(event), "end_time" => event.time.iso8601)
          
          # Track against event
          event.add_open_graph(fbid["id"])
      end
    rescue
      Rails.logger.info "FACEBOOK POST ORGANISE GAME ERROR: " + $!.to_s
    end

    # post a play in game action for user
    def post_play_in_game_action(user, teamsheet_entry, invite_response)

      # We'll roll this out, and only post if user is acting on himslef
      if $rollout.active?(:fb_post_play_in, user) && (!user.nil? && user.id == teamsheet_entry.user_id) && teamsheet_entry.open_graph_play_in.nil?
          
          graph = self.get_graph_object(user)
          return if graph.nil?

          if invite_response.response_status==1
            fbid = graph.put_connections("me", Facebook::NAMESPACE.to_s + ":play_in", "game" => Rails.application.routes.url_helpers.url_for(teamsheet_entry.event), "end_time" => teamsheet_entry.event.time.iso8601)
            teamsheet_entry.add_open_graph(fbid["id"])
          elsif !teamsheet_entry.open_graph_play_in.nil?
            graph.delete_object(teamsheet_entry.open_graph_play_in.fbid)
          end
      end
    rescue
      Rails.logger.info "FACEBOOK ERROR: " + $!.to_s
    end

    def get_graph_object(user)
      fbauth = user.authorizations.find_by_provider("Facebook")
      graph = fbauth.nil? ? nil : Koala::Facebook::GraphAPI.new(fbauth.token)
    end

    # here so we can call from sidekiq
    def fetch_user_profile_image(user_id, auth_token)
      pic_url = "http://graph.facebook.com/#{auth_token.uid}/picture?type=large"

      user = User.find(user_id)
      
      # no begin/rescue, so we can watch it fail in sidekiq
      user.profile.profile_picture = open(pic_url)
      user.profile.save!
      logger.info "Failed to update profile picture from fb for user #{user.id}"
    end

  end
end