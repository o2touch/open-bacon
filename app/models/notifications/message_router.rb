module Onyx
  class MessageRouter
    def self.routing_pipeline
      [
        TeamRoleMessageRoutingPipe,
        TeamInviteMessageRoutingPipe,
        TeamSummaryMessageRoutingPipe,
        LeagueTeamInviteMessageRoutingPipe,
        LeagueTeamRoleMessageRoutingPipe,
        DivisionSchedulePublishedPipe,
        EventRescheduledRoutingPipe,
        EventPostponedRoutingPipe
      ]
    end

    def route(message)
      message_obj = message['class'].constantize.find(message['id'])

      was_not_consumed = true
      MessageRouter.routing_pipeline.each do |pipe|
        if pipe.can_process?(message_obj)
          pipe.worker.perform_async(message)
          was_not_consumed = false
        end
      end

      DeadMessageRoutingPipe.worker.perform_async(message) if was_not_consumed and DeadMessageRoutingPipe.can_process?(message_obj)
    end

    class EventRescheduledRoutingPipe
      class << self
        def worker
          EventRescheduledWorker  
        end

        def can_process?(message_obj)
          message_obj.class == NotificationItem and message_obj.subj_type == User.name and message_obj.verb == 'rescheduled' and message_obj.obj_type == Event.name
        end
      end
    end

    class EventPostponedRoutingPipe
      class << self
        def worker
          EventPostponedWorker  
        end

        def can_process?(message_obj)
          message_obj.class == NotificationItem and message_obj.subj_type == User.name and message_obj.verb == 'postponed' and message_obj.obj_type == Event.name
        end
      end
    end

    class DeadMessageRoutingPipe
      class << self
        def worker
          DeadMessageWorker  
        end

        def can_process?(message_obj)
          #Performance critical code block
          #Messages filtered in this block are non recoverable.
          true
        end
      end
    end

    class DivisionSchedulePublishedPipe
      class << self
        def worker
          DivisionSchedulePublishedWorker
        end

        def can_process?(message_obj)
          message_obj.class == NotificationItem and message_obj.subj_type == League.name and ['schedule_published'].include?(message_obj.verb) and message_obj.obj_type == DivisionSeason.name
        end
      end
    end

    class LeagueTeamRoleMessageRoutingPipe
      class << self
        def worker
          LeagueTeamRoleMessageWorker
        end

        def can_process?(message_obj)
          #Performance critical code block
          (
            message_obj.class == NotificationItem and 
            message_obj.subj_type == League.name and 
            message_obj.verb == VerbEnum::CREATED and 
            message_obj.obj_type == PolyRole.name
          )
        end
      end
    end

    class LeagueTeamInviteMessageRoutingPipe
      class << self
        def worker
          LeagueTeamInviteMessageWorker
        end

        def can_process?(message_obj)
          #Performance critical code block
          (
            message_obj.class == NotificationItem and 
            message_obj.subj_type == League.name and 
            message_obj.verb == VerbEnum::CREATED and 
            message_obj.obj_type == TeamInvite.name
          )
        end
      end
    end

    class TeamRoleMessageRoutingPipe
      class << self
        def worker
          TeamRoleMessageWorker
        end

        def can_process?(message_obj)
          #Performance critical code block
          (
            message_obj.class == NotificationItem and 
            message_obj.subj_type != League.name and 
            [VerbEnum::DESTROYED, VerbEnum::CREATED].include?(message_obj.verb) and 
            message_obj.obj_type == PolyRole.name
          )
        end
      end
    end

    class TeamInviteMessageRoutingPipe
      class << self
        def worker
          TeamInviteMessageWorker
        end

        def can_process?(message_obj)
          #Performance critical code block
          (
            message_obj.class == NotificationItem and 
            message_obj.subj_type != League.name and 
            message_obj.verb == VerbEnum::CREATED and 
            message_obj.obj_type == TeamInvite.name
          )
        end
      end
    end

    class TeamSummaryMessageRoutingPipe
      class << self
        def worker
          TeamSummaryMessageWorker
        end

        def can_process?(message_obj)
          #Performance critical code block
          (
            message_obj.class == NotificationItem and 
            message_obj.subj_type != League.name and 
            [VerbEnum::DESTROYED, VerbEnum::CREATED].include?(message_obj.verb) and 
            [TeamInvite.name, PolyRole.name].include?(message_obj.obj_type)
          )
        end
      end
    end
  end
end
