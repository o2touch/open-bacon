require 'spec_helper'
include EventUpdateHelper

describe EventMailer do
  context 'not parents' do 
    before :each do
      @user = FactoryGirl.create :user 
      @parent = FactoryGirl.create :user 
      @junior = FactoryGirl.create :junior_user 
      @event = FactoryGirl.create :event, game_type: 0 
      @team = FactoryGirl.create :team, :with_events, event_count: 1
      @event.team = @team
      @org = @team.organisers.first
      @league = FactoryGirl.create :league 
      @tenant_id = Tenant.first.id

      @data = {
        event_id: 1,
        actor_id: 2,
        team_id: 1,
        junior_id: 3,
      }

      @diff = {
        title: ["old title", "new title"],
        time: [@event.time, @event.time + 1.day]
      }
      @data[:updates] = pretty_event_atributes(@diff)


      Event.stub(find: @event)
      Team.stub(find: @team)
      League.stub(find: @league)
      User.stub(:find) do |arg|
        u = @user if arg == 1
        u = @org if arg == 2
        u = @junior if arg == 3
        u = @parent if arg == 4
        u
      end
    end

    describe '#player_event_created' do
      it 'should be a nice email' do
        mail = EventMailer.player_event_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("Game Added")
        body.should match("game")
        body.should match("View game details")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("You have a new game coming up")
      end
    end

    describe '#player_event_postponed' do
      it 'should be a nice postponed email' do
        mail = EventMailer.player_event_postponed(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("postponed")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("Your game has been postponed!")
      end
    end

    describe '#player_event_resheduled' do
      it 'should be a nice postponed email' do
        mail = EventMailer.player_event_rescheduled(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("rescheduled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("Your game has been rescheduled!")
      end
    end

    describe '#player_event_cancelled' do
      it 'should send a nice cancelled email' do
        mail = EventMailer.player_event_cancelled(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("Cancelled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("Your game has been cancelled!")
      end
    end

    describe '#player_event_activated' do
      it 'should be a nice postponed email' do
        mail = EventMailer.player_event_activated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("no longer cancelled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("Your game is back on!")
      end
    end

    describe '#player_event_updated' do
      it 'should be a nice email' do
        mail = EventMailer.player_event_updated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("updated")
        body.should match("game")
        body.should match(@diff[:title][1])
        body.should match(BFTimeLib.bf_format(@diff[:time][1]))

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("Your game has been updated")
      end
    end

    describe '#player_event_invite_reminder' do
      it 'should be a nice email' do
        AddPlayerToEventWorker.new.perform(@event, @user, true)
        @data[:tse_id] = TeamsheetEntry.find_by_event_and_user(@event, @user)

        mail = EventMailer.player_event_invite_reminder(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("are you available?")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject(/Reminder: Can you play in the game at/)       
      end
    end

    describe '#follower_event_created' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("Game Added")
        body.should match("game")
        body.should match("View Game Details")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A new game has been added")
      end
    end

    describe '#follower_event_postponed' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_postponed(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("postponed")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A game has been postponed!")
      end
    end

    describe '#follower_event_rescheduled' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_rescheduled(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("rescheduled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A game has been rescheduled!")
      end
    end

    describe '#follower_event_cancelled' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_cancelled(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("Game Cancelled!")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A game has been cancelled!")
      end
    end

    describe '#follower_event_activated' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_activated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("back on")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A game is back on!")
      end
    end

    describe '#follower_event_updated' do
      it 'should be a nice email' do
        mail = EventMailer.follower_event_updated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("updated")
        body.should match("game")
        body.should match(@diff[:title][1])

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("A game has been updated")
      end
    end

    describe '#'
  end

  context 'parents' do
    before :each do
      @user = FactoryGirl.create :user 
      @parent = FactoryGirl.create :user 
      @junior = FactoryGirl.create :junior_user 
      @event = FactoryGirl.create :event, game_type: 0 
      @team = FactoryGirl.create :team, :with_events, event_count: 1
      @event.team = @team
      @org = @team.organisers.first
      @league = FactoryGirl.create :league 
      @tenant_id = 1

      @data = {
        event_id: 1,
        actor_id: 2,
        team_id: 1,
        junior_id: 3,
      }

      @diff = {
        title: ["old title", "new title"]
      }
      @data[:updates] = pretty_event_atributes(@diff)

      Event.stub(find: @event)
      Team.stub(find: @team)
      League.stub(find: @league)
      User.stub(:find) do |arg|
        u = @user if arg == 1
        u = @org if arg == 2
        u = @junior if arg == 3
        u = @parent if arg == 4
        u
      end
    end

    describe '#parent_event_created' do
      it 'should be a nice email' do
        mail = EventMailer.parent_event_created(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("#{@junior.first_name.titleize} has a new game coming up")
      end
    end

    describe '#parent_event_cancelled' do
      it 'should be a nice email' do
        mail = EventMailer.parent_event_cancelled(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("cancelled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("#{@junior.first_name.titleize}'s game has been cancelled!")
      end
    end

    describe '#parent_event_activated' do
      it 'should be a nice postponed email' do
        mail = EventMailer.parent_event_activated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("no longer cancelled")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("#{@junior.first_name.titleize}'s game is back on!")
      end
    end

     describe '#parent_event_updated' do
      it 'should be a nice email' do
        mail = EventMailer.parent_event_updated(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("updated")
        body.should match("game")
        body.should match(@diff[:title][1])

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject("#{@junior.first_name.titleize}'s game has been updated")
      end
    end

    describe '#parent_event_reminder' do
      it 'should be a nice email' do
        AddPlayerToEventWorker.new.perform(@event, @user, true)
        @data[:tse_id] = TeamsheetEntry.find_by_event_and_user(@event, @user)

        mail = EventMailer.parent_event_invite_reminder(1, @tenant_id, @data)
        body = mail.body.encoded

        body.should match(@team.name.upcase)
        body.should match(@event.title)
        body.should match("coming up and")
        body.should match("needs to know if")
        body.should match("game")

        mail.should deliver_to("#{@user.name.titleize} <#{@user.email}>")
        mail.should deliver_from("#{@team.name} <#{NOTIFICATIONS_FROM_ADDRESS}>")
        mail.should have_subject(/Reminder: Can [A-Z][a-z]+ play in the game at/)       
      end
    end
  end
end