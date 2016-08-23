object @goal_checklist_item

node :complete do |goal_checklist_item|
  goal_checklist_item.complete?
end
    
node :key do |goal_checklist_item|
  goal_checklist_item.key
end
