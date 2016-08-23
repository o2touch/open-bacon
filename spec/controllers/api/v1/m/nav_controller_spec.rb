require 'spec_helper'

describe Api::V1::M::NavController do
	describe '#show' do

		it 'does the shit it is meant to do' do
			# Was most of the way of stubbing shit out.. but it was slower to run the test,
			#   so I stopped. TS
			@div1 = FactoryGirl.create :division_season
			@league = @div1.league
			@div2 = FactoryGirl.create :division_season, league: @league
			@league.save
			@div2.save

			@t1 = FactoryGirl.create :team
			TeamDSService.add_team(@div1, @t1)

			user = @t1.organisers.first
			signed_in user
			get :show

			body = JSON.parse(response.body)
			body["teams"].count.should eq(1)
			body["user"].should_not be_empty
			body["leagues"].count.should eq(1)
			body["leagues"][0]["divisions"].count.should eq(1)
		end
	end
end