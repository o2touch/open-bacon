require 'spec_helper'

describe PolyRole do
  describe 'factory' do
    it 'returns a valid PolyRole object' do
      user = FactoryGirl.build(:user)
      team = FactoryGirl.build(:team)
      obj = FactoryGirl.build(:poly_role, :user => user, :obj => team, :role_id => RoleEnum::INVITED)
    end
  end
end
