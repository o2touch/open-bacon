object false

node :data do
  partial "api/v1/activity_items/index", :object => @activity_items
end


node :next_page do
  @next_page
end

node :previous_page do 
  @previous_page
end
