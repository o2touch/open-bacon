require 'spec_helper'

include KmHelper

describe KmHelper do 

  describe "#track_email" do

    context "with one parameter" do
      before :each do
        time = Time.new(2020,01,01,0,0,0)
        recipient_id = "bob@gmail.com"
        email_name = "Message Email"
        params = "TeamId=3&time=#{time.to_i}"
        
        @html = track_email(recipient_id, email_name, params)
      end

      # it "creates the correct img html" do
      #   @html.should == '<img src="http://api.mixpanel.com/track/?data=eyJldmVudCI6IlZpZXdlZCBFbWFpbCBFbWFpbCIsInByb3BlcnRpZXMiOnsi+VGVhbUlkIjoiMyJ9LCJkaXN0aW5jdF9pZCI6IiIsInRva2VuIjoiIiwidGlt+ZSI6MTM3MjQ0Mzg3MX0=+&ip=1&img=1"/>'
      # end

      it "contains the correct data and structure" do

        query = @html.split("?")
        query_hash = {}

        query[1].split("&").each do |p|
          key,val = p.split("=")
          query_hash[key] = val unless val.nil?
        end

        encoded_str = query_hash['data'].gsub('-','+').gsub('_','/')
        encoded_str += '=' while !(encoded_str.size % 4).zero?

        decoded = Base64.decode64(encoded_str)
        @decoded_params = JSON.parse(decoded.to_s)

        @decoded_params['properties']['distinct_id'].should == "bob@gmail.com"
        @decoded_params['properties']['TeamId'].should == "3"
        @decoded_params['event'].should == "Viewed Email Message Email"
      end
    end

    context "with a parameter hash" do
      before :each do
        time = Time.new(2020,01,01,0,0,0)
        recipient_id = "bob@gmail.com"
        email_name = "Message Email"

        params = {}
        params["TeamId"] = "3"
        params["time"] = time.to_i
        
        @html = track_email(recipient_id, email_name, params)
      end

      # it "creates the correct img html" do
      #   @html.should == '<img src="http://api.mixpanel.com/track/?data=eyJldmVudCI6IlZpZXdlZCBFbWFpbCBFbWFpbCIsInByb3BlcnRpZXMiOnsi+VGVhbUlkIjoiMyJ9LCJkaXN0aW5jdF9pZCI6IiIsInRva2VuIjoiIiwidGlt+ZSI6MTM3MjQ0Mzg3MX0=+&ip=1&img=1"/>'
      # end

      it "contains the correct data and structure" do

        query = @html.split("?")
        query_hash = {}

        query[1].split("&").each do |p|
          key,val = p.split("=")
          query_hash[key] = val unless val.nil?
        end

        encoded_str = query_hash['data'].gsub('-','+').gsub('_','/')
        encoded_str += '=' while !(encoded_str.size % 4).zero?

        decoded = Base64.decode64(encoded_str)
        @decoded_params = JSON.parse(decoded.to_s)

        @decoded_params['properties']['distinct_id'].should == "bob@gmail.com"
        @decoded_params['properties']['TeamId'].should == "3"
        @decoded_params['event'].should == "Viewed Email Message Email"
      end
    end

  end

  describe "#get_img_html" do

    context "with one parameter" do
      before :each do
        time = Time.new(2020,01,01,0,0,0)
        title = "Message+Email"
        params = "bob@gmail.com&TeamId=3&time=#{time.to_i}"
        
        @html = get_img_html(title, params)
      end

      # it "creates the correct img html" do
      #   @html.should == '<img src="http://api.mixpanel.com/track/?data=eyJldmVudCI6IlZpZXdlZCBFbWFpbCBFbWFpbCIsInByb3BlcnRpZXMiOnsi+VGVhbUlkIjoiMyJ9LCJkaXN0aW5jdF9pZCI6IiIsInRva2VuIjoiIiwidGlt+ZSI6MTM3MjQ0Mzg3MX0=+&ip=1&img=1"/>'
      # end

      it "contains the correct data and structure" do

        query = @html.split("?")
        query_hash = {}

        query[1].split("&").each do |p|
          key,val = p.split("=")
          query_hash[key] = val unless val.nil?
        end

        encoded_str = query_hash['data'].gsub('-','+').gsub('_','/')
        encoded_str += '=' while !(encoded_str.size % 4).zero?

        decoded = Base64.decode64(encoded_str)
        @decoded_params = JSON.parse(decoded.to_s)

        @decoded_params['properties']['distinct_id'].should == "bob@gmail.com"
        @decoded_params['properties']['TeamId'].should == "3"
        @decoded_params['event'].should == "Viewed Email Message Email"
      end
    end

  end

  describe "#encode_hash" do

    context "with one parameter" do
      before :each do
        
        params = {}
        params["EventId"] = 4

        @encoded_hash = encode_hash(params)

        decoded = Base64.decode64(@encoded_hash)
        @decoded_params = JSON.parse(decoded)
      end

      it "can be decoded" do
        @decoded_params["EventId"].should == 4
      end
    end

  end

  describe "#convert_url_params_to_hash" do

    context "with one parameter" do
      before :each do
        params = "bob@gmail.com&TeamId=3"
        @hash = convert_url_params_to_hash(params)
      end

      it "creates the correct hash" do
        @hash["TeamId"].should == "3"
      end

      it "hash does not include email" do
        @hash.size.should == 1
      end
    end

    context "with two parameters" do
      before :each do
        params = "bob@gmail.com&TeamId=3&EventId=4"
        @hash = convert_url_params_to_hash(params)
      end

      it "creates the correct hash" do
        @hash["TeamId"].should == "3"
        @hash["EventId"].should == "4"
      end
    end

  end

end