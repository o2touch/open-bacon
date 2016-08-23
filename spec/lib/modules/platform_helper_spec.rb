require 'spec_helper'

describe PlatformHelper do

  describe "#get_platform_from_params" do

    context "when mobile parameters are set" do
      let(:params) do
        {
          app_instance_id: 1,
          app_version: "1.5"
        }
      end

      it "returns mobile platform hash" do
        hash = PlatformHelper.get_platform_from_params(params)

        hash[:platform].should == "mobile"
        hash[:app_tenant].should == 1
        hash[:app_version].should == "1.5"
      end

    end

    context "when some mobile parameters are set" do
      let(:params) do
        {
          app_version: "1.5"
        }
      end

      it "returns mobile platform hash" do
        hash = PlatformHelper.get_platform_from_params(params)

        hash[:platform].should == "mobile"
        hash[:app_tenant].should be_nil
        hash[:app_version].should "1.5"
      end

    end

    context "when w{eb parameters are set" do
      let(:params) { Hash.new }

      it "returns mobile platform hash" do
        hash = PlatformHelper.get_platform_from_params(params)

        hash[:platform].should == "web"
        hash[:app_tenant].should be_nil
        hash[:app_version].should be_nil
      end

    end

  end

end