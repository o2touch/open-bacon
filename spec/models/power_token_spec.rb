require 'spec_helper'

describe PowerToken do
	context 'validations' do
		it 'does not allow non-unique tokens' do
			t1 = PowerToken.create(route: "/tim")
			t2 = PowerToken.new(route: "/sonny")
			t2.stub!(:generate_token).and_return(nil)
			expect { t2.save! }.to raise_error
		end

		it 'requires at token' do
			token = PowerToken.new(route: "/sonny")
			token.stub!(:generate_token).and_return(nil)
			expect { token.save! }.to raise_error
		end

		it 'requires a route' do
			expect { PowerToken.create! }.to raise_error
		end
	end	

	context 'callbacks' do
		it 'calls generate_token before_validation' do
			token = PowerToken.create(route: "/tim")
			token.token.should_not be_nil
		end
	end	

	describe 'find_active_token' do
		it 'does not return disabled tokens' do
			token = PowerToken.create(route: "/tim", disabled: true)
			PowerToken.find_active_token(token.token).should be_nil
		end
		it 'does not return expired tokens' do
			token = PowerToken.create(route: "/tim", expires_at: 1.day.ago)
			PowerToken.find_active_token(token.token).should be_nil
		end
		it 'returns the right power token' do
			(1..4).each do |i|
				PowerToken.create(route: "/#{i}")
			end
			token = PowerToken.find(2)
			PowerToken.find_active_token(token.token).id.should eq(2)
		end
	end

	describe 'generate_token' do
		it 'returns different things if you call it twice as this is an excellent test for uniqueness' do
			token = PowerToken.create(route: "/tim")
			t1 = token.token
			token.generate_token
			t1.should_not eq(token.token)
		end
	end
end