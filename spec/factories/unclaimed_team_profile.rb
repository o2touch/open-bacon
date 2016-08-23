FactoryGirl.define do  

  sequence :name do |n|
    "Test Unclaimed Team Name #{n}"
  end

  sequence :token do |n|
    "Test Token #{n}"
  end

  factory :unclaimed_team_profile do |p|
    p.name
    p.token 
    p.team_id nil
    p.location nil
    p.league_name "Test League Name"
    p.contact_name "Test Name"
    p.contact_number "+123456789"
    p.contact_email "Test Email"
    p.sport { fg_sport }
    p.colour1 { fg_colour }
    p.colour2 { fg_colour }
  end
end