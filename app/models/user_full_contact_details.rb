class UserFullContactDetails < ActiveRecord::Base
  attr_accessible :email, :full_contact_json, :photo_url
end
