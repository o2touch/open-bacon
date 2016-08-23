require 'spec_helper'

describe Tenants::ReportsController, :type => :controller  do
  
  describe '#show' do

    before :each do
      @tenant = Tenant.find(2)
    end

    context "logged out" do
      context 'authentication' do
        it 'is performed' do
          signed_out
          get :show, tenant_name: @tenant.name
          response.status.should eq(401)
        end
      end
    end

    context "when has ability to read_reports for tenant" do

      before :each do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        @controller.stub(:current_ability).and_return(@ability)
      end

      it 'reports is rendered' do
          @ability.can :read_reports, Tenant

          get :show, tenant_name: @tenant.name
          assert_template(:show_overview)
          response.status.should eq(200)
      end

    end

  end

  describe '#show_participation' do

    before :each do
      @tenant = Tenant.find(2)
    end

    context "logged out" do
      context 'authentication' do
        it 'is performed' do
          signed_out
          get :show_participation, tenant_name: @tenant.name
          response.status.should eq(401)
        end
      end
    end

    context "when has ability to read_reports for tenant" do

      before :each do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        @controller.stub(:current_ability).and_return(@ability)
      end

      it 'reports is rendered' do
          @ability.can :read_reports, Tenant

          get :show_participation, tenant_name: @tenant.name
          assert_template(:show_participation)
          response.status.should eq(200)
      end
    end
  end

  describe '#show_engagement' do

    before :each do
      @tenant = Tenant.find(2)
    end

    context "logged out" do
      context 'authentication' do
        it 'is performed' do
          signed_out
          get :show_engagement, tenant_name: @tenant.name
          response.status.should eq(401)
        end
      end
    end

    context "when has ability to read_reports for tenant" do

      before :each do
        @ability = Object.new
        @ability.extend(CanCan::Ability)
        @controller.stub(:current_ability).and_return(@ability)
      end

      it 'reports is rendered' do
          @ability.can :read_reports, Tenant

          get :show_engagement, tenant_name: @tenant.name
          assert_template(:show_engagement)
          response.status.should eq(200)
      end
    end
  end

end