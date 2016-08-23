require "spec_helper"

describe "routing to Api/V1 ActivityItemsLikes" do

    let(:activity_item_id) { "1" }

    it "routes /api/v1/activity_items/1/comments to api/v1/activity_items_comments#index" do
      { :get => "/api/v1/activity_items/#{activity_item_id}/comments" }.should route_to("api/v1/activity_item_comments#index", :api_v1_activity_item_id => activity_item_id)
    end

    it "routes /api/v1/activity_items/1/comments to api/v1/activity_items_comments#create" do
      { :post => "/api/v1/activity_items/#{activity_item_id}/comments" }.should route_to("api/v1/activity_item_comments#create", :api_v1_activity_item_id => activity_item_id)
    end

    it "routes /api/v1/activity_items/1/comments/1 to api/v1/activity_items_comments#show" do
      { :get => "/api/v1/activity_items/#{activity_item_id}/comments/1" }.should route_to("api/v1/activity_item_comments#show", :api_v1_activity_item_id => activity_item_id, :id => "1")
    end

    it "routes /api/v1/activity_items/1/comments/1 to api/v1/activity_items_comments#update" do
      { :put => "/api/v1/activity_items/#{activity_item_id}/comments/1" }.should route_to("api/v1/activity_item_comments#update", :api_v1_activity_item_id => activity_item_id, :id => "1")
    end

    it "routes /api/v1/activity_items/1/comments/1 to api/v1/activity_items_comments#destroy" do
      { :delete => "/api/v1/activity_items/#{activity_item_id}/comments/1" }.should route_to("api/v1/activity_item_comments#destroy", :api_v1_activity_item_id => activity_item_id, :id => "1")
    end

end