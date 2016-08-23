require 'spec_helper'

describe DownloadController do

  context "#app_store_redirect" do

    include AppStoreLinkHelper

    subject { get :app_store_redirect }

    context "when iPhone device" do

      before(:each) do

        user_agent = "Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
        browser = UserAgent.parse(user_agent)

        UserAgent.stub(:parse).and_return(browser)
      end

      it "redirects to itunes store" do
        subject.should redirect_to(itunes_url)
      end

    end

    context "when iPad device" do

      before(:each) do

        user_agent = "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25"
        browser = UserAgent.parse(user_agent)

        UserAgent.stub(:parse).and_return(browser)
      end

      it "redirects to itunes store" do
        subject.should redirect_to(itunes_url)
      end

    end

    context "when Android 2.2.1 device" do

      before(:each) do
        user_agent = "Mozilla/5.0 (Linux; U; Android 2.2.1; en-gb; HTC_DesireZ_A7272 Build/FRG83D) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1"
        browser = UserAgent.parse(user_agent)

        UserAgent.stub(:parse).and_return(browser)
      end

      it "redirects to play store" do
        subject.should redirect_to(play_store_url)
      end

    end

    context "when Android 4.0.3 device" do

      before(:each) do
        user_agent = "Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30"
        browser = UserAgent.parse(user_agent)

        UserAgent.stub(:parse).and_return(browser)
      end

      it "redirects to play store" do
        subject.should redirect_to(play_store_url)
      end

    end

  end


  context "#send_install_link" do

    context "when mobile number" do

      context "is US" do

        before :each do
          @mobile_number = "+12345678912"
        end

        it "attempts to send text" do
          TwilioService.should_receive(:send_download_link).with(@mobile_number)

          params = {
            :to => @mobile_number,
            :time => Time.now.to_i
          }

          token = Digest::MD5.hexdigest(params[:to] + params[:time].to_s + "SUPERSECRETHASH")

          post :send_install_link, :to => params[:to], :time => params[:time], :token => token, format: :json
          assert_response 200
        end
      
        context "and misformated" do
          it "attempts to send text" do

            @mobile_number = "+1 (234) 567 8981"

            TwilioService.should_receive(:send_download_link).with("+12345678981")

            post :send_install_link, :to => @mobile_number, format: :json
            assert_response 200
          end
        end

        context "no international prefix" do
          before :each do
            request.stub(:remote_ip).and_return("68.224.154.22")# US IP
          end
          it "attempts to send text" do

            @mobile_number = "(234) 567 8981"

            TwilioService.should_receive(:send_download_link).with("+12345678981")

            post :send_install_link, :to => @mobile_number, format: :json
            assert_response 200
          end
        end

      end

      context "is UK" do

        before :each do
          @mobile_number = "+447779303173"
        end

        it "attempts to send text" do
          TwilioService.should_receive(:send_download_link).with(@mobile_number)

          post :send_install_link, :to => @mobile_number, format: :json
          assert_response 200
        end
      
        context "and misformated" do
          it "attempts to send text" do

            @mobile_number = "+44 07779 303 173"

            TwilioService.should_receive(:send_download_link).with("+447779303173")

            post :send_install_link, :to => @mobile_number, format: :json
            assert_response 200
          end
        end

        context "no international prefix" do
          before :each do
            @mobile_number = "07779303173"
            request.stub(:remote_ip).and_return("31.222.128.0")
          end
          it "attempts to send text" do
            TwilioService.should_receive(:send_download_link).with("+447779303173")

            post :send_install_link, :to => @mobile_number, format: :json
            assert_response 200
          end
        end

      end

    end

    context "when invalid mobile number" do

      it "responds 406" do
        mobile_number = "+1 (234)"
        post :send_install_link, :to => mobile_number, format: :json
        assert_response 422
      end

    end
    

    context "when not json" do
      it "responds 406" do
        mobile_number = "+1 (234) 567 8981"
        post :send_install_link, :to => mobile_number, format: :html
        assert_response 406
      end
    end

    context "when not incorrect parameters" do
      it "responds 406" do
        post :send_install_link, format: :html
        assert_response 422
      end
    end

  end

end