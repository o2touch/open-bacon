require 'spec_helper'

class FakeWorker
  class << self
    def perform_async(message)
      true
    end
  end
end

class FakeRoutingPipe
  class << self
    def worker
      FakeWorker  
    end

    def can_process?(message_obj)
      true
    end
  end
end

describe Onyx::MessageRouter do
  context 'route' do
    it 'routes messages to the correct message worker' do
      routing_pipeline = [ FakeRoutingPipe ]

      Onyx::MessageRouter.stub(:routing_pipeline).and_return(routing_pipeline)

      fake_model = mock_model("FakeModel")
      FakeModel.stub(:find).and_return(fake_model)

      message = {
        'class' => FakeModel.name,
        'id' => 1
      }

      FakeRoutingPipe.worker.should_receive(:perform_async).once.with(message)
      Onyx::MessageRouter::DeadMessageRoutingPipe.worker.should_receive(:perform_async).exactly(0).times.with(message)

      Onyx::MessageRouter.new.route(message)
    end

    it 'routes messages to the dead queue if no worker consumes the message' do
      FakeRoutingPipe.stub(:can_process?).and_return(false)
      routing_pipeline = [ FakeRoutingPipe ]

      Onyx::MessageRouter.stub(:routing_pipeline).and_return(routing_pipeline)

      fake_model = mock_model("FakeModel")
      FakeModel.stub(:find).and_return(fake_model)

      message = {
        'class' => FakeModel.name,
        'id' => 1
      }

      FakeRoutingPipe.worker.should_receive(:perform_async).exactly(0).times.with(message)
      Onyx::MessageRouter::DeadMessageRoutingPipe.worker.should_receive(:perform_async).once.with(message)

      Onyx::MessageRouter.new.route(message)
    end
  end

  context 'DeadMessageRoutingPipe' do
    it 'does not reject any messages' do
      Onyx::MessageRouter::DeadMessageRoutingPipe.can_process?(nil).should be_true
    end
  end

  context 'LeagueTeamRoleMessageRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::LeagueTeamRoleMessageRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages it should process' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(League.name)

      Onyx::MessageRouter::LeagueTeamRoleMessageRoutingPipe.can_process?(mock_message).should be_true
    end
  end

  context 'LeagueTeamInviteMessageRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::LeagueTeamInviteMessageRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages it should process' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(TeamInvite.name)
      mock_message.stub(:subj_type).and_return(League.name)

      Onyx::MessageRouter::LeagueTeamInviteMessageRoutingPipe.can_process?(mock_message).should be_true
    end
  end

  context 'TeamRoleMessageRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::TeamRoleMessageRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages for team role creations' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamRoleMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'accepts messages for team role deletions' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamRoleMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'rejects messages for leagues' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(League.name)

      Onyx::MessageRouter::TeamRoleMessageRoutingPipe.can_process?(mock_message).should be_false
    end
  end

  context 'TeamInviteMessageRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::TeamInviteMessageRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages it should process' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(TeamInvite.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamInviteMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'rejects messages for leagues' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(TeamInvite.name)
      mock_message.stub(:subj_type).and_return(League.name)

      Onyx::MessageRouter::TeamInviteMessageRoutingPipe.can_process?(mock_message).should be_false
    end
  end

  context 'TeamSummaryMessageRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::TeamSummaryMessageRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages for team invite creations' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(TeamInvite.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamSummaryMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'accepts messages for team role creations' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::CREATED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamSummaryMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'accepts messages for team role deletions' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::TeamSummaryMessageRoutingPipe.can_process?(mock_message).should be_true
    end

    it 'rejects messages for leagues' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::DESTROYED)
      mock_message.stub(:obj_type).and_return(PolyRole.name)
      mock_message.stub(:subj_type).and_return(League.name)

      Onyx::MessageRouter::TeamSummaryMessageRoutingPipe.can_process?(mock_message).should be_false
    end
  end

  context 'EventPostponedRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::EventPostponedRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages it should process' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::POSTPONED)
      mock_message.stub(:obj_type).and_return(Event.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::EventPostponedRoutingPipe.can_process?(mock_message).should be_true
    end
  end

  context 'EventRescheduledRoutingPipe' do
    it 'rejects messages it cannot process' do
      Onyx::MessageRouter::EventRescheduledRoutingPipe.can_process?(nil).should be_false
    end

    it 'accepts messages it should process' do
      mock_message = mock_model(NotificationItem)
      mock_message.stub(:verb).and_return(VerbEnum::RESCHEDULED)
      mock_message.stub(:obj_type).and_return(Event.name)
      mock_message.stub(:subj_type).and_return(User.name)

      Onyx::MessageRouter::EventRescheduledRoutingPipe.can_process?(mock_message).should be_true
    end
  end
end
