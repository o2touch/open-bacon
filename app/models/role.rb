class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :roles_users
  
  attr_accessible :name

  def self.cache_find_by_name(role_name)
    Role
    calmelized_role_name = role_name.to_s.camelize
    cache_key = "Role/#{calmelized_role_name}"

    begin 
      Rails.cache.fetch cache_key do
        Role.find_by_name(calmelized_role_name)
      end
    rescue
      Role.find_by_name(calmelized_role_name)
    end
  end
end
