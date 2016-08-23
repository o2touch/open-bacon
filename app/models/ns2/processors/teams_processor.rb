class Ns2::Processors::TeamsProcessor < Ns2::Processors::Base
  class << self
    protected
    # All protected methods get called within a transaction, thus, I'm
    #   very willing for us to make loads of assumptions in the code below -
    #   if shit fucks up nothing will be created, it'll just be retried until
    #   we fix it

    # Also, each method is expected to return an array of notification items

    # 'verb' is noun+verb here as schedule isn't an object...
    # This app event is now only triggered by a division being launched
    def schedule_created(app_event)
      team = app_event.obj
      return [] unless team.schedule_updates? 
      event_ids = app_event.obj.future_events.map(&:id)
      generate_nis(app_event, "schedule_created", event_ids)
    end

    # This app event is now only triggered by a division being published
    def schedule_updated(app_event)
      team = app_event.obj
      return [] unless team.schedule_updates? 
      event_ids =  team.updated_events.map(&:id)
      generate_nis(app_event, "schedule_updated", event_ids)
    end

    private
    def generate_nis(app_event, datum, event_ids)
      nis = []

      team = app_event.obj

      # ******* HACK FOR VOLITUDE ********
      return [] if team.leagues.map(&:id).include? 4

      players = team.players.to_a
      organisers = team.organisers.to_a
      plorganisers = players.concat(organisers).uniq

      meta_data = {
        team_id: team.id,
        event_ids: event_ids,
        actor_id: app_event.subj.id
      }
      meta_data[:league_id] =  app_event.meta_data[:league_id] if app_event.meta_data.has_key? :league_id

      team.associates.each do |a|
        next if a == app_event.subj # don't notify the actor
        next if a.junior? # don't notify juniors

        tenant = LandLord.new(team).tenant

        # Let's check the general users notifications policy
        unp = UserNotificationsPolicy.new(a, tenant)
        next unless unp.should_notify?

        # Let's check the user notifications policy for this team
        next unless UserTeamNotificationPolicy.new(a, team).should_notify?(datum)

        md = meta_data.clone

        # organiser, or player
        if team.has_organiser?(a) || team.has_player?(a)
          md[:team_invite_id] = TeamInvite.get_invite(team, a).id unless a.role?(RoleEnum::REGISTERED)
          nis << email_ni(app_event, a, tenant, "player_#{datum}", md) if unp.can_email? # send both, innit
          nis << push_ni(app_event, a, tenant, "player_#{datum}", md) if unp.can_push?
        # parent
        elsif team.has_parent? a
          md[:team_invite_id] = TeamInvite.get_invite(team, a).id unless a.role?(RoleEnum::REGISTERED)
          md[:junior_ids] = team.get_players_in_team(a.children.to_a).map(&:id)
          nis << email_ni(app_event, a, tenant, "parent_#{datum}", md) if unp.can_email?
          nis << push_ni(app_event, a, tenant, "parent_#{datum}", md) if unp.can_push?
        # follower
        else
          nis << email_ni(app_event, a, tenant, "follower_#{datum}", md) if unp.can_email?
          nis << push_ni(app_event, a, tenant, "follower_#{datum}", md) if unp.can_push?
        end
      end

      # update the team to know when it last sent out a schedule.
      team.update_attribute(:schedule_last_sent, Time.now)

      nis
    end
  end
end