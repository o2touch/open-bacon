class EmailNotificationService
  class << self
    def filter_demo_user_notifications(user)
      user.type == 'DemoUser'
    end

    # Exit edit mode

    # moved to Division.rb, and now done per division, rather than league
    # TODO: SVSL HACK: This needs to be moved. League admins should be able to trigger this 
    #                  once, and only hit the edit fixture publish button once subsequent 
    #                  schedule changes have been made.
    # def exit_league_edit_mode(league_id)
    #   league = League.find(league_id)
    #   league.divisions.each do |div|
    #     div.teams.each do |team|
    #       # Email organisers with special email team onboarding role
    #       team.team_roles.where(:role_id => 2).each do |team_role|
    #         #Create a TeamInvite for use in the email sent to the organiser to allow them to login
    #         TeamInvite.get_invite(team, team_role.user, nil) 
    #         EmailNotificationService.notify_league_created_team_role(team_role, league)
    #       end
    #       # Email players
    #       team.team_roles.where(:role_id => 1).where("user_id NOT IN (?)", team.organisers.map(&:id)).each do |team_role|
    #         ti = TeamInvite.get_invite(team, team_role.user, nil)
    #         EmailNotificationService.notify_league_team_invite_created(ti, league)
    #       end

    #       # update the team to know when it last sent out a schedule.
    #       team.update_attribute(:schedule_last_sent, Time.now)
    #     end
    #   end
    # end

    # End exit edit mode

    # Leagues

    # This sends a league team invitation email, and an inital event schedule
    def notify_league_created_team_role(team_role, league)
      return if EmailNotificationService.filter_demo_user_notifications(team_role.user)

      return if NotificationItem.where(:subj_id => league.id, :obj_id => team_role.id, :verb => :created).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = league
      notification_item.obj = team_role
      notification_item.verb = :created
      notification_item.meta_data = {
        :team_name => team_role.team.name,
        :team_id => team_role.team_id,  
        :user_name => team_role.user.name,
        :user_id => team_role.user_id,
        :role_id => team_role.role_id,
        :created_at => team_role.created_at
      }
      notification_item.save!

      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    # This sends a league team invitation email, and an initial event schedule
    def notify_league_team_invite_created(team_invite, league)
      return if EmailNotificationService.filter_demo_user_notifications(team_invite.sent_to)

      return if NotificationItem.where(:subj_id => league.id, :obj_id => team_invite.id, :verb => :created).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = league
      notification_item.obj = team_invite
      notification_item.verb = :created
      notification_item.save!
      
      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    # This sends a schedule updated email.
    # TODO: change this to/also add a notify event changed, and agregate. TS
    def notify_division_schedule_published(division)
      notification_item = NotificationItem.new
      notification_item.subj = division.league
      notification_item.obj = division
      notification_item.verb = :schedule_published
      notification_item.meta_data = { :time_published => Time.now } # not actually used, yet
      notification_item.save!

      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    # End Leagues

    def notify_destroyed_team_role(team_role, actioned_by)
      return if EmailNotificationService.filter_demo_user_notifications(team_role.user)

      return if NotificationItem.where(:subj_id => actioned_by.id, :obj_id => team_role.id, :verb => :destroyed).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = actioned_by
      notification_item.obj = team_role
      notification_item.verb = :destroyed
      notification_item.meta_data = {
        :team_name => team_role.obj.name,
        :team_id => team_role.obj_id,  
        :user_name => team_role.user.name,
        :user_id => team_role.user_id,
        :role_id => team_role.role_id,
        :created_at => team_role.created_at
      }
      notification_item.save!

      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    def notify_created_team_role(team_role, actioned_by)
      return if EmailNotificationService.filter_demo_user_notifications(team_role.user)

      return if NotificationItem.where(:subj_id => actioned_by.id, :obj_id => team_role.id, :verb => :created).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = actioned_by
      notification_item.obj = team_role
      notification_item.verb = :created
      notification_item.meta_data = {
        :team_name => team_role.obj.name,
        :team_id => team_role.obj_id,  
        :user_name => team_role.user.name,
        :user_id => team_role.user_id,
        :role_id => team_role.role_id,
        :created_at => team_role.created_at
      }
      notification_item.save!

      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    def notify_team_invite_created(team_invite, actioned_by)
      return if EmailNotificationService.filter_demo_user_notifications(team_invite.sent_to)

      return if NotificationItem.where(:subj_id => actioned_by.id, :obj_id => team_invite.id, :verb => :created).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = actioned_by
      notification_item.obj = team_invite
      notification_item.verb = :created
      notification_item.save!
      
      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    def send_postpone_notifications(event, diff, actioned_by)

      return if NotificationItem.where(:subj_id => actioned_by.id, :obj_id => event.id, :verb => :postponed).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = actioned_by
      notification_item.obj = event
      notification_item.verb = :postponed
      notification_item.save!
      
      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end

    def send_rescheduled_notifications(event, diff, actioned_by)

      return if NotificationItem.where(:subj_id => actioned_by.id, :obj_id => event.id, :verb => :rescheduled).count > 0

      notification_item = NotificationItem.new
      notification_item.subj = actioned_by
      notification_item.obj = event
      notification_item.verb = :rescheduled
      notification_item.save!
      
      MessageRouterWorker.perform_async({'id' => notification_item.id, 'class' => NotificationItem.name})
      notification_item
    end
  end
end

























