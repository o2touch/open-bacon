require 'spec_helper'

describe 'GoalChecklistItem' do

  context 'organiser completed event page' do
    before (:each) do
      @user = mock_model(User)
      @user.stub(:get_setting)
      @item = OrganiserCompletedEventPage.new(@user)
    end

    it 'is complete if the organiser completed_event_page flag is set' do
      @user.should_receive(:get_setting).and_return(true)
      @item.complete?.should be_true
    end

    it 'is not complete if the organiser completed_event_page flag is not set' do
      @user.should_receive(:get_setting).and_return(false)
      @item.complete?.should be_false
    end

    it 'generates the correct json' do
      @user.should_receive(:get_setting).and_return(true)
      @item.to_json.should == { :complete => true, :key => :organiser_completed_event_page }
    end
  end

  context 'team created one event' do
    before (:each) do
      @team = mock_model(Team)
      @team.stub(:events)
      @item = TeamCreatedOneEvent.new(@team)
    end

    it 'is complete if the team has 1 event' do
      @team.should_receive(:events).and_return(["event 1"])
      @item.complete?.should be_true
    end

    it 'is complete if the team has at least 1 event' do
      @team.should_receive(:events).and_return(["event 1", "event 2"])
      @item.complete?.should be_true
    end

    it 'is not complete if the team has 0 events' do
      @team.should_receive(:events).and_return([])
      @item.complete?.should be_false
    end

    it 'generates the correct json' do
      @team.should_receive(:events).and_return(["event 1"])
      @item.to_json.should == { :complete => true, :key => :team_created_one_event }
    end
  end

  context 'team added schedule' do
    before (:each) do
      @team = mock_model(Team)
      @team.stub(:events)
      @item = TeamAddedSchedule.new(@team)
    end

    it 'is complete if the team has 4 events' do
      @team.should_receive(:events).and_return(["event 1", "event 2", "event 3", "event 4"])
      @item.complete?.should be_true
    end

    it 'is complete if the team has at least 4 event' do
      @team.should_receive(:events).and_return(["event 1", "event 2", "event 3", "event 4", "event 5"])
      @item.complete?.should be_true
    end

    it 'is not complete if the team less than 4 events' do
      @team.should_receive(:events).and_return(["event 1"])
      @item.complete?.should be_false
    end

    it 'generates the correct json' do
      @team.should_receive(:events).and_return(["event 1", "event 2", "event 3", "event 4"])
      @item.to_json.should == { :complete => true, :key => :team_added_schedule }
    end
  end

  context 'team enroled four players' do
    def mock_player(id)
      player = mock_model(User)
      player.stub(id:id)
      return player
    end

    before (:each) do
      @founder = mock_player("founder")
      @player1 = mock_player("player1")
      @player2 = mock_player("player2")
      @player3 = mock_player("player3")
      @player4 = mock_player("player4")
      @player5 = mock_player("player5")

      @demo_player = mock_player("demo_player")

      @team = mock_model(Team)
      @team.stub(founder:@founder)
      @team.stub(demo_players:[@demo_player])

      @item = TeamEnroledFourPlayers.new(@team)
    end

    it 'is complete if the team has at least 4 players' do
      @team.should_receive(:players).and_return([@player1, @player2, @player3, @player4])
      @item.complete?.should be_true
    end

    it 'is complete if the team has at least 4 players excluding demo players' do
      @team.should_receive(:players).and_return([@demo_player, @player1, @player2, @player3, @player4])
      @item.complete?.should be_true
    end

    it 'is not complete if the team has 4 players including demo players' do
      @team.should_receive(:players).and_return([@demo_player, @player1, @player2, @player3])
      @item.complete?.should be_false
    end

    it 'is not complete if the team has at least 4 players including the founder' do
      @team.should_receive(:players).and_return([@founder, @player1, @player2, @player3])
      @item.complete?.should be_false
    end

     it 'is complete if the team has at least 4 players' do
      @team.should_receive(:players).and_return([@player1, @player2, @player3, @player4, @player5])
      @item.complete?.should be_true
    end

    it 'is not complete if the team less than 4 players' do
      @team.should_receive(:players).and_return([@player1])
      @item.complete?.should be_false
    end

    it 'generates the correct json' do
      @team.should_receive(:players).and_return([@player1, @player2, @player3, @player4])
      @item.to_json.should == { :complete => true, :key => :team_enroled_four_players }
    end
  end
end
