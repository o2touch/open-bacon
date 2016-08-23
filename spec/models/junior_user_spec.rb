require 'spec_helper'

describe User do
  context 'junior user factory' do
    it "is valid with build" do
      junior = FactoryGirl.build(:junior_user)
      junior.should be_valid
      junior.profile.should be_valid
      junior.roles.should have_exactly(0).items
      junior.parents.should be_empty
      junior.dob.should > 13.years.ago
    end

    it "is valid with create" do
      #A parent is associated with a junior via a Relation object.
      #We must create these objects so IDs are assigned and persisted for the assoication to exist.
      junior = FactoryGirl.create(:junior_user)
      junior.should be_valid
      junior.profile.should be_valid
      junior.roles.should have_exactly(3).items
      junior.parents.should_not be_nil
      junior.dob.should > 13.years.ago
    end

    # it 'adds a registered role in an fg after create callback' do
    #   junior = FactoryGirl.create(:junior_user)
    #   junior.roles.count.should eq(3)
 			# role_names = junior.roles.map{ |role| role.name }
 			# role_names.should include(RoleEnum::REGISTERED)
    # end
  end

 	context 'callbacks' do
 		it 'should add a no login role after_create' do
 			junior = FactoryGirl.build(:junior_user)
 			lambda{ junior.save }.should change(junior.roles, :count).by(2)
 			role_names = junior.roles.map{ |role| role.name }
 			role_names.should include(RoleEnum::NO_LOGIN)
 		end
 	end

  context 'callbacks' do
    it 'should add a junior role after_create' do
      junior = FactoryGirl.build(:junior_user)
      lambda{ junior.save }.should change(junior.roles, :count).by(2)
      role_names = junior.roles.map{ |role| role.name }
      role_names.should include(RoleEnum::JUNIOR)
    end
  end

 	context 'validations' do
 		it 'can be valid when has no parent' do
 			junior = FactoryGirl.create(:junior_user)
 			junior.unassociate_parent(junior.parents.first)
 			junior.should be_valid
 		end

 		it 'must not have an email address' do
 			junior = FactoryGirl.build(:junior_user)
 			junior.email = "anythign@gmail.org.uk"
 			junior.should_not be_valid
 		end

 		it 'must not have a mobile number' do
 			junior = FactoryGirl.build(:junior_user)
 			junior.mobile_number = "1234567890"
 			junior.should_not be_valid
 		end
 	end
end