class NotificationItem < ActiveRecord::Base 
  belongs_to :subj, :polymorphic => true
  belongs_to :obj, :polymorphic => true  
  has_many :email_notifications

  serialize :meta_data, Hash

  validates :subj, :presence => true
  validates :obj, :presence => true
  validates :verb, :presence => true

  def notifications
    #Concatenate new notifcation types here.
    email_notifications
  end
end
