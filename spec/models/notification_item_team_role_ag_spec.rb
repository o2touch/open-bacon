require 'spec_helper'
require 'sidekiq/testing'

describe NotificationItemTeamRoleAg do
  describe 'process' do 
    def build_mock_team_invite(team_id, verb, user_id, created_at)
      mock_user = double('user')
      mock_user.stub(:id).and_return(user_id)
      mock_user.stub(:name).and_return("name")
      mock_user.stub(:created_at).and_return(Time.now)

      object_with_team_id = double('object_with_team_id')
      object_with_team_id.stub(:team_id).and_return(team_id)
      object_with_team_id.stub(:sent_to).and_return(mock_user)
      object_with_team_id.stub(:created_at).and_return(created_at)

      mock_notification_item = mock_model(NotificationItem)
      mock_notification_item.stub(:obj).and_return(object_with_team_id)
      mock_notification_item.stub(:verb).and_return(verb)
      mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)
      mock_notification_item.stub(:meta_data).and_return({})

      mock_notification_item
    end

    def build_mock_team_role(team_id, verb, role_id, user_id, created_at)
      object_with_team_id = double('object_with_team_id')
      object_with_team_id.stub(:team_id).and_return(team_id)
      
      mock_notification_item = mock_model(NotificationItem)
      mock_notification_item.stub(:obj).and_return(object_with_team_id)
      mock_notification_item.stub(:verb).and_return(verb)
      mock_notification_item.stub(:obj_type).and_return(PolyRole.name)
      
      mock_notification_item.stub(:meta_data).and_return({
        :id => mock_notification_item.id,
        :user_name => "name",
        :user_id => user_id,
        :role_id => role_id,
        :created_at => created_at,
        :team_id => team_id
      })

      mock_notification_item
    end

    def setup_notification_item_processor(team_id, organisers)
      relation = double('relation')
      relation.stub(:update_all)
      NotificationItem.stub(:where).and_return(relation)
      
      mock_organiser = mock_model(User)
      mock_team = mock_model(Team)
      mock_team.stub(:organisers).and_return(organisers)
      Team.stub(:find).and_return(mock_team)

      NotificationItemTeamRoleAg.new(team_id)
    end

    it 'processes team organiser role created messages', :sidekiq => false do
      team_id = 1

      mock_team_role = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::ORGANISER, 1, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      invited_organisers = [processor.send(:extract_team_role_data, mock_team_role)]

      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], [], invited_organisers, [])

      processor.process([mock_team_role]).should be_true
    end

    it 'processes team invite messages', :sidekiq => false do
      team_id = 1

      mock_team_invite = build_mock_team_invite(team_id, VerbEnum::CREATED, 1, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      created_team_invites = [processor.send(:extract_team_invite_data, mock_team_invite)]

      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], [], [], created_team_invites)

      processor.process([mock_team_invite]).should be_true
    end

    it 'processes team organiser role destroyed messages', :sidekiq => false do
      team_id = 1

      mock_team_role = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::ORGANISER, 1, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      destroyed_team_roles = [processor.send(:extract_team_role_data, mock_team_role)]

      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, destroyed_team_roles, [], [], [])

      processor.process([mock_team_role]).should be_true
    end

    it 'processes team player role destroyed messages', :sidekiq => false do
      team_id = 1

      mock_team_role = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::PLAYER, 1, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      destroyed_team_roles = [processor.send(:extract_team_role_data, mock_team_role)]

      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], destroyed_team_roles, [], [])

      processor.process([mock_team_role]).should be_true
    end

    it 'emails all team organisers', :sidekiq => false do
      team_id = 1

      mock_team_role = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::PLAYER, 1, Time.now)
      
      organisers = [mock_model(User), mock_model(User)]

      processor = setup_notification_item_processor(team_id, organisers)
      
      destroyed_team_roles = [processor.send(:extract_team_role_data, mock_team_role)]

      organisers.each do |organiser|
        TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, organiser.id, [], destroyed_team_roles, [], [])
      end

      processor.process([mock_team_role]).should be_true
    end

    it 'processes multiple messages', :sidekiq => false do
      team_id = 1

      mock_team_role_a = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::PLAYER, 1, Time.now)
      mock_team_role_b = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::PLAYER, 2, Time.now)
      mock_team_role_c = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::PLAYER, 3, Time.now)
      mock_team_role_d = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::PLAYER, 4, Time.now)
      mock_team_invite_e = build_mock_team_invite(team_id, VerbEnum::CREATED, 5, Time.now)
      mock_team_invite_f = build_mock_team_invite(team_id, VerbEnum::CREATED, 6, Time.now)
      mock_team_role_g = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::ORGANISER, 7, Time.now)
      mock_team_role_h = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::ORGANISER, 8, Time.now)
      mock_team_role_i = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::ORGANISER, 9, Time.now)
      mock_team_role_j = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::ORGANISER, 10, Time.now)

      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      destroyed_player_team_roles = [mock_team_role_a, mock_team_role_c].map {|x| processor.send(:extract_team_role_data, x) }
      created_player_team_roles = [mock_team_role_b, mock_team_role_d].map {|x| processor.send(:extract_team_role_data, x) }
      created_team_invites = [mock_team_invite_e, mock_team_invite_f].map {|x| processor.send(:extract_team_invite_data, x) }
      destroyed_organiser_team_roles = [mock_team_role_g, mock_team_role_i].map {|x| processor.send(:extract_team_role_data, x) }
      created_organiser_team_roles = [mock_team_role_h, mock_team_role_j].map {|x| processor.send(:extract_team_role_data, x) }
      
      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(
        team_id, 
        mock_organiser.id, 
        destroyed_organiser_team_roles,
        destroyed_player_team_roles, 
        created_organiser_team_roles, 
        (created_player_team_roles | created_team_invites)
      )

      notification_items = [mock_team_role_a, mock_team_role_b, mock_team_role_c, mock_team_role_d, mock_team_role_g, mock_team_role_h, mock_team_role_i, mock_team_role_j, mock_team_invite_e, mock_team_invite_f]
      processor.process(notification_items).should be_true
    end

    it 'processes and aggregates multiple messages', :sidekiq => false do
      team_id = 1

      mock_team_role_a = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::PLAYER, 1, Time.now)
      mock_team_role_b = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::PLAYER, 1, Time.now)
      mock_team_invite_c = build_mock_team_invite(team_id, VerbEnum::CREATED, 2, Time.now)
      mock_team_invite_d = build_mock_team_invite(team_id, VerbEnum::CREATED, 2, Time.now)
      mock_team_role_e = build_mock_team_role(team_id, VerbEnum::DESTROYED, PolyRole::ORGANISER, 3, Time.now)
      mock_team_role_f = build_mock_team_role(team_id, VerbEnum::CREATED, PolyRole::ORGANISER, 3, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      created_team_invites = [mock_team_invite_d].map {|x| processor.send(:extract_team_invite_data, x) }
      
      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], [], [], created_team_invites)

      notification_items = [mock_team_role_a, mock_team_role_b, mock_team_invite_c, mock_team_invite_d, mock_team_role_e, mock_team_role_f]
      processor.process(notification_items).should be_true
    end

    it 'adheres to the time order messages arrive', :sidekiq => false do
      team_id = 1

      mock_team_invite_a = build_mock_team_invite(team_id, VerbEnum::CREATED, 1, Time.now)
      mock_team_invite_b = build_mock_team_invite(team_id, VerbEnum::CREATED, 1, Time.now)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      created_team_invites = [mock_team_invite_b].map {|x| processor.send(:extract_team_invite_data, x) }
      
      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], [], [], created_team_invites)

      notification_items = [mock_team_invite_a, mock_team_invite_b]
      processor.process(notification_items).should be_true
    end

    it 'discards duplicate messages with the same timestamp', :sidekiq => false do
      team_id = 1
      time = Time.now

      mock_team_invite_a = build_mock_team_invite(team_id, VerbEnum::CREATED, 1, time)
      mock_team_invite_b = build_mock_team_invite(team_id, VerbEnum::CREATED, 1, time)
      
      mock_organiser = mock_model(User)
      processor = setup_notification_item_processor(team_id, [mock_organiser])
      
      created_team_invites = [mock_team_invite_b].map {|x| processor.send(:extract_team_invite_data, x) }
      
      TeamOrganiserMailer.should_receive(:aggregated_team_roles).once.with(team_id, mock_organiser.id, [], [], [], created_team_invites)

      notification_items = [mock_team_invite_a, mock_team_invite_b]
      processor.process(notification_items).should be_true
    end
  end

  describe 'can_process' do
    def build_mock_notification_item
      team_id = 1
      object_with_team_id = double('object_with_team_id')
      object_with_team_id.stub(:team_id).and_return(team_id)

      mock_notification_item = double('notification_item')
      mock_notification_item.stub(:obj).and_return(object_with_team_id)
      mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
      mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)
      mock_notification_item.stub(:meta_data).and_return({})

      mock_notification_item
    end
    
    it 'accepts message if the obj_type is recognised' do
      mock_notification_item = build_mock_notification_item
      processor = NotificationItemTeamRoleAg.new(mock_notification_item.obj.team_id)

      mock_notification_item.stub(:obj_type).and_return(TeamInvite.name)
      processor.can_process?(mock_notification_item).should be_true

      mock_notification_item.stub(:obj_type).and_return(PolyRole.name)
      processor.can_process?(mock_notification_item).should be_true
    end

    it 'rejects message if the obj_type is not recognised' do
      mock_notification_item = build_mock_notification_item
      processor = NotificationItemTeamRoleAg.new(mock_notification_item.obj.team_id)

      mock_notification_item.stub(:obj_type).and_return('Object')
      processor.can_process?(mock_notification_item).should be_false
    end

    it 'accepts message if the verb is recognised' do
      mock_notification_item = build_mock_notification_item
      processor = NotificationItemTeamRoleAg.new(mock_notification_item.obj.team_id)

      mock_notification_item.stub(:verb).and_return(VerbEnum::CREATED)
      processor.can_process?(mock_notification_item).should be_true

      mock_notification_item.stub(:verb).and_return(VerbEnum::DESTROYED)
      processor.can_process?(mock_notification_item).should be_true
    end

    it 'rejects message if the verb is not recognised' do
      mock_notification_item = build_mock_notification_item
      processor = NotificationItemTeamRoleAg.new(mock_notification_item.obj.team_id)

      mock_notification_item.stub(:verb).and_return('edited')
      processor.can_process?(mock_notification_item).should be_false
    end

    it 'rejects message if it is not for the specified team' do
      mock_notification_item = build_mock_notification_item
      team_id = 2
      mock_notification_item.obj.team_id.should_not == team_id
      processor = NotificationItemTeamRoleAg.new(team_id)

      processor.can_process?(mock_notification_item).should be_false
    end

    it 'asserts team_id against meta_data if present for TeamRole specific notification items' do
      mock_notification_item = build_mock_notification_item
      meta_data = { :team_id => 1 }
      mock_notification_item.stub(:meta_data).and_return(meta_data)
      mock_notification_item.stub(:obj_type).and_return(PolyRole.name)
      mock_notification_item.stub(:obj).and_return(nil)

      team_id = 2
      processor = NotificationItemTeamRoleAg.new(team_id)

      processor.can_process?(mock_notification_item).should be_false
    end
  end
end
