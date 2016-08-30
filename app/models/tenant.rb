class Tenant < ActiveRecord::Base
  include Configurable
  include Roleable

  # This defines where notifications should be sent to, rather than the
  #  only palce that this tenant's data should (neccessarily) be accessed. TS
  belongs_to :mobile_app

  # has_many :tenant_roles created via Roleable
  has_many :organisers,
            :source => :user,
            :through => :tenant_roles,
            :conditions => ['role_id = ?', PolyRole::ORGANISER]

  # i18n is used for if we want to display a different version of the copy for a tenant,
  # (rather than different langauages)
	attr_accessible :name, :subdomain, :i18n, :colour_1, :colour_2, :mobile_app_id

  # prob remove this, innit
  #	serialize :settings, {}

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
    :path => "#{ENV['S3_BUCKET']}/tenent_logos/:id/:style/:filename",
    :url => "/system/tenent_logos/:id/:style/:filename", :default_url => "/assets/profile_pic/team/generic_team_:style.png"

  # TODO: Add some uniq validation on names and 
	validates :name, presence: true, uniqueness: true

  # Config setup ting
  configurable # default settings

  # Setup roles on dis ting
  roleable roles: [PolyRole::ORGANISER]

  # DEPRACATED - USE THE ONE ON THE LANDLORD
  def self.get_default_tenant
    self.find(TenantEnum::MITOO_ID)
  end

  def default_tenant?
    self.id == TenantEnum::MITOO_ID
  end

  def get_domain
    host = $ROOT_DOMAIN
    host = "#{self.subdomain}.#{host}" unless self.subdomain.blank?

    host
  end
end