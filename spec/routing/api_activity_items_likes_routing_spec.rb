require "spec_helper"

describe "routing to Api/V1 ActivityItemsLikes" do

    let(:activity_item_id) { "1" }

    it "routes /api/v1/activity_items/1/likes to api/v1/activity_items_likes#create" do
      { :post => "/api/v1/activity_items/#{activity_item_id}/likes" }.should route_to("api/v1/activity_item_likes#create", :api_v1_activity_item_id => activity_item_id)
    end

    it "routes to #destroy" do
      { :delete => "/api/v1/activity_items/#{activity_item_id}/likes" }.should route_to("api/v1/activity_item_likes#destroy", :id => activity_item_id)
    end

end