require 'spec_helper'

describe EventResult do

  context 'win' do
    it 'should report a win given score_against < score_for' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => 1).won?.should be_true
    end

    it 'should report nil if score_for is not a number' do
      FactoryGirl.create(:event_result, :score_for => "A", :score_against => 1).won?.should be_nil
    end

    it 'should report nil if score_against is not a number' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => "A").won?.should be_nil
    end
  end

  context 'lose' do
    it 'should report a loss given score_against > score_for' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => 3).lost?.should be_true
    end

    it 'should report nil if score_for is not a number' do
      FactoryGirl.create(:event_result, :score_for => "A", :score_against => 1).lost?.should be_nil
    end

    it 'should report nil if score_against is not a number' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => "A").lost?.should be_nil
    end
  end

  context 'lose' do
    it 'should report a draw given score_against == score_for' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => 2).draw?.should be_true
    end

    it 'should report nil if score_for is not a number' do
      FactoryGirl.create(:event_result, :score_for => "A", :score_against => 1).lost?.should be_nil
    end

    it 'should report nil if score_against is not a number' do
      FactoryGirl.create(:event_result, :score_for => 2, :score_against => "A").lost?.should be_nil
    end
  end
end
