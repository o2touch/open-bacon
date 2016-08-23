class Authorization < ActiveRecord::Base
  attr_accessible :provider, :uid, :user_id, :token, :secret, :name, :link
  
  belongs_to :user
  validates :provider, :uid, :presence => true
end
