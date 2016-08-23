require 'spec_helper'

describe EventMessage do
  it 'validates the presence of the message' do
    FactoryGirl.build(:event_message, :text => nil).valid?.should be_false
  end

  it 'validates the miniumum length of the message' do
    FactoryGirl.build(:event_message, :text => "").valid?.should be_false
    FactoryGirl.build(:event_message, :text => "x").valid?.should be_true
  end

  it 'validates the maximum length of the message' do
    FactoryGirl.build(:event_message, :text => "x"*FieldValidation::MAXIMUM_MESSAGE_LENGTH).valid?.should be_true
    FactoryGirl.build(:event_message, :text => "x"*(FieldValidation::MAXIMUM_MESSAGE_LENGTH+1)).valid?.should be_false
  end

  describe 'validate_model_ids' do
    it 'validates no nils are present in the id array'
    it 'validates string and int id array'
    it 'returns true if model_ids are valid'
    it 'returns false if model_ids are not valid'
    it 'ignores model lookup failures'
    it 'validates models are part of the valid set'
    it 'validates models of type model_constant'
  end

  describe 'recipients_hash_to_user' do
    before :each do
      @event = FactoryGirl.create(:event, :with_players)
      @player = @event.teamsheet_entries.last.user

      @event.teamsheet_entries.each do |x|
        ir = x.invite_responses.create!(
          response_status: InviteResponseEnum.values.sample,
          created_by: x.user
        )
      end
      @event.reload

      @message = FactoryGirl.create(:event_message, 
        :messageable => @event, :user => @player, 
        :meta_data => {}, 
        :text => 'vadar with light saber tooth like a tiger night rider')

      @availability_summary = @event.availability_summary_obj
    end

    it 'returns the correct user objects in the available response group' do
      meta_data = {
        'users' => [],
        'groups' => [MessageGroups::AVAILABLE]
      }

      expected_recipients = @availability_summary[:available]
      @message.recipients_hash_to_user(meta_data).map(&:id).sort.should == expected_recipients.map(&:id).sort
    end

    it 'returns the correct user objects in the unavailable response group' do
      meta_data = {
        'users' => [],
        'groups' => [MessageGroups::UNAVAILABLE]
      }

      expected_recipients = @availability_summary[:unavailable]
      @message.recipients_hash_to_user(meta_data).map(&:id).sort.should == expected_recipients.map(&:id).sort
    end

    it 'returns the correct user objects in the awaiting response group' do
      meta_data = {
        'users' => [],
        'groups' => [MessageGroups::AWAITING]
      }

      expected_recipients = @availability_summary[:awaiting]
      @message.recipients_hash_to_user(meta_data).map(&:id).sort.should == expected_recipients.map(&:id).sort
    end

    it 'returns the correct user objects for multiple response groups' do
      meta_data = {
        'users' => [],
        'groups' => [MessageGroups::AWAITING, MessageGroups::AVAILABLE]
      }

      expected_recipients = @availability_summary[:awaiting] | @availability_summary[:available]
      @message.recipients_hash_to_user(meta_data).map(&:id).sort.should == expected_recipients.map(&:id).sort
    end
  end
end
