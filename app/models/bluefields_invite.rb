class BluefieldsInvite < ActiveRecord::Base
  has_one :sent_by, :class_name => "User"
  
  attr_accessible :sent_by, :sent_to_email, :source
  
  after_create :send_invite_email
  
  def send_invite_email
    UserMailer.delay.bluefields_invite(self)
  end
  
end
