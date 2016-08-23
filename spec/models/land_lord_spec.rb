require 'spec_helper'

describe LandLord do 
	# To explain this shit... we grab the method called (via method_missing), and call it
	#  on the object that's supplied as an arg. We then (assume that we get back an array
	#  of tenanted objects and) filter the response for being the correct tenant.
  #  However, as the mitoo app should return everything, we take care of that too.
	describe 'tenanting of arrays from arbitrary method calls' do
		before :each do
			# create the teams
			@teams = []
			(1..4).each do |i|
				@teams << FactoryGirl.build(:team, tenant_id: (i%2)+1)
			end
			@obj = double(teams: @teams)
		end

		context 'single tenant selected' do
			it 'should call the method on the obj, and filter the results' do
				ll = LandLord.new(MobileApp.find_by_name("o2_touch"))
				ll.teams(@obj).size.should eq(2)
			end
		end

		context 'all tenants selected' do
			it 'should call the method on the obj, and not filter the results' do
				ll = LandLord.new(MobileApp.find_by_name("mitoo"))
				ll.teams(@obj).size.should eq(4)
			end
		end
	end
end