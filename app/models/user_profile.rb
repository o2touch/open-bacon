class UserProfile < ActiveRecord::Base
  MINIMUM_BIO_LENGTH = 1
  MAXIMUM_BIO_LENGTH = 120

  has_one :user  #SR - Why doesnt a user have one user profile?
  belongs_to :location

  has_attached_file :profile_picture, 
    :styles => { :large => "300x300#", :medium=> "120x120#", :small => "60x60#", :thumb => "30x30#" }, 
    :path => "#{ENV['S3_BUCKET']}/user_profile_pictures/:id/:style/:filename",
    :url => "/system/user_profile_pictures/:id/:style/:filename",
    :default_url => "/assets/profile_pic/user/generic_user_:style.png"
  # validates_attachment_content_type :profile_picture, :content_type => %w(image/jpeg image/jpg image/png)
  
  attr_accessible :user_id, :bio, :location_id, :dob, :gender

  validates_length_of :bio, :minimum => MINIMUM_BIO_LENGTH, :maximum => MAXIMUM_BIO_LENGTH, :allow_nil => true, :allow_blank => true
  validates :gender, inclusion: { in: ["m", "f"] }, allow_nil: true
  
  def profile_picture_thumb_url
    self.profile_picture.url(:thumb)
  end
   
  def profile_picture_medium_url
    self.profile_picture.url(:medium)
  end

  def profile_picture_small_url
    self.profile_picture.url(:small)
  end
  
  def profile_picture_large_url
    self.profile_picture.url(:large)
  end
  
  def as_json(options={})
    super(options.merge({:methods => [:profile_picture_thumb_url,:profile_picture_medium_url,:profile_picture_small_url,:profile_picture_large_url]}))
  end
end
