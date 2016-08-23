class ContactRequest < ActiveRecord::Base
  attr_accessible :data, :demo, :email, :message, :name, :organisation, :mobile
end
