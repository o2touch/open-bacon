require 'spec_helper'

describe AggregateMessageManager do
  class Clazz 
  end

  it 'adds messages into its team bucket' do
    model_id = 1
    team_id = 1
    clazz = Clazz.new
    Clazz.stub(:find)
    Clazz.should_receive(:find).once.with(model_id).and_return(clazz)
    team = double('team_role')
    team.stub(:team_id).and_return(team_id)

    clazz.stub(:obj).and_return(team)
    clazz.stub(:verb).and_return('created')
    clazz.stub(:obj_type).and_return(PolyRole.name)

    message = {
      :args => [
        {
          :class => Clazz.name,
          :id => model_id,
        }
      ],
    }.to_json

    bucket = double('bucket')
    bucket.stub(:add_item)
    bucket.should_receive(:add_item).once.with(clazz)

    manager = AggregateMessageManager.new
    manager.should_receive(:create_team_bucket).once.with(team_id).and_return(bucket)

    manager.bucket_message(message)
  end
end
