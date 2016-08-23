class ActivityItemLink < ActiveRecord::Base    

  belongs_to :feed_owner, :polymorphic => true
  belongs_to :activity_item

  attr_accessible :feed_type

end
