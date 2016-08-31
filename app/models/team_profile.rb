class TeamProfile < ActiveRecord::Base
  has_one :team, foreign_key: :profile_id
  
  attr_accessible :age_group, :colour1, :colour2, :league_name, :sport, :profile_picture

  has_attached_file :profile_picture, 
    :styles => { 
      :large => "300x300#",
      :medium=> "120x120#",
      :small => "60x60#",
      :thumb => "30x30#",
      :large_original_ratio  => "300x300",
      :medium_original_ratio => "120x120",
      :small_original_ratio  => "60x60",
      :thumb_original_ratio  => "30x30"
    }, 
    :path => "team_profile_pictures/:id/:style/:filename",
    :url => "/system/team_profile_pictures/:id/:style/:filename",
    :default_url => "/assets/profile_pic/team/generic_team_:style.png"
  
  # validates_attachment_content_type :profile_picture, :content_type => %w(image/jpeg image/jpg image/png)

  # process_in_background :profile_picture
  
  validates :sport, presence: true, inclusion: { in: SportsEnum.values }
  validates :colour1, :colour2, presence: true
  validate :colours_unless_from_league
  validates :age_group, presence: true, inclusion: { in: AgeGroupEnum.values }

  def colours_unless_from_league
    return
    return unless self.team.nil? || self.team.faft_team? || self.team.created_by_type != "League"

    if !ColourEnum.values.include?(self.colour1)
      errors.add(:colour1, "The team's primary colour is not allowed")
    end
    if !ColourEnum.values.include?(self.colour2)
      errors.add(:colour2, "The team's secondary colour is not allowed")
    end
  end

  # override the getter, and return tenant colours, if required
  def colour1
    return self.team.tenant.colour_1 if !self.team.nil? && self.team.config.style_override_colours
    read_attribute(:colour1)
  end

  # override the getter, and return tenant colours, if required
  def colour2
    return self.team.tenant.colour_2 if !self.team.nil? && self.team.config.style_override_colours
    read_attribute(:colour2)
  end
  
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
  
  def profile_picture_thumb_original_ratio_url
    self.profile_picture.url(:thumb_original_ratio)
  end
   
  def profile_picture_medium_original_ratio_url
    self.profile_picture.url(:medium_original_ratio)
  end
  
  def profile_picture_small_original_ratio_url
    self.profile_picture.url(:small_original_ratio)
  end
  
  def profile_picture_large_original_ratio_url
    self.profile_picture.url(:large_original_ratio)
  end
  
end
