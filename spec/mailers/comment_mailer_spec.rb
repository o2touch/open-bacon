require 'spec_helper'

describe CommentMailer do
	describe '#message_comment_created' do
    before(:each) do
      @recipient = FactoryGirl.create(:user, :name => "Bob", :email => "bob@gmail.com") 

      @event_message = FactoryGirl.create(:event_message_with_comments)

      @event = FactoryGirl.create(:event)

      @event_message.messageable = @event

      @activity_item = @event_message.activity_item
      @activity_item.obj = @event_message

      @comment = @activity_item.comments.first
      @user = @comment.user

	    data = {
	    	comment_id: @comment.id,
	    	actor_id: @user.id,
	    	activity_item_id: @activity_item.id,
	    	feed_owner_type: "Event",
	    	feed_owner_id: @event.id
	    }

	    @mail = CommentMailer.message_comment_created(@recipient.id, tenant_id=1, data)
    end 

    it "should contain 'comment posted'" do
      @mail.body.encoded.should match("#{@user.name} has commented")
    end

    it "should contain deliver to bob@gmail.com" do
      @mail.should deliver_to("Bob <bob@gmail.com>")
    end
	end

	describe '#invite_response_comment_created' do
	  before(:each) do
	  	@team = FactoryGirl.create :team, :with_events, :with_players, event_count: 1, player_count: 2
			@commenter = @team.players.second
			@original_poster = @team.organisers.first

			EventInvitesService.add_players(@team.events.first, @team.players, false)

			tse = @team.events.first.teamsheet_entries.first
			@ir = TeamsheetEntriesService.set_availability(tse, 1)
			@comment = @ir.activity_items.first.create_comment(@commenter, "HI")

	    @recipient = FactoryGirl.create(:user)

	    data = {
	    	comment_id: @comment.id,
	    	actor_id: @commenter.id,
	    	activity_item_id: @ir.activity_items.first.id,
	    	feed_owner_type: "Event",
	    	feed_owner_id: @team.events.first.id
	    }

	    @mail = CommentMailer.invite_response_comment_created(@recipient.id, tenant_id=1, data)
	  end 

	  it "should contain 'comment posted'" do
	    @mail.body.encoded.should match("#{@commenter.name} has commented")
	  end
	end
end