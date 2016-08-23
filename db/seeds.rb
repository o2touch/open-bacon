# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Role.delete_all
RoleEnum.values.each { |role| Role.create({ name: role}) }

# faft robot...
User.delete(1)
User.create!(id: 1, email: 'faft_robot@bluefields.com', name: 'FAFT Robot', time_zone: 'Europe/London', country: 'GB')

MobileApp.create(name: "o2_touch", token: ENV['O2TOUCH_APP_TOKEN'])

# stolen from setup_configurable.rake to get some basic tenant shit
MITOO_CONFIG = {
	team_joinable: false,
	team_public: false,
	team_followable: false
} unless defined? MITOO_CONFIG
MITOO_ATTRS = {
	i18n: "mitoo",
	sms: true,
	email: true,
	mobile_app_id: 1
} unless defined? MITOO_ATTRS

t = Tenant.create!(id: 1, name: 'mitoo', subdomain: '')

t.config.clear_all!
"#{t.name.upcase}_CONFIG".constantize.each do |k, v|
	t.config.send("#{k}=".to_sym, v)
end
"#{t.name.upcase}_ATTRS".constantize.each do |k, v|
	t.send("#{k}=".to_sym, v)
end	
t.save

# WARNING: not fully configured
O2_TOUCH_ATTRS = {
	i18n: "o2_touch",
	sms: false,
	email: true,
	mobile_app_id: 2,
	colour_1: '1A245C',
	colour_2: '900f29'
} unless defined? O2_TOUCH_ATTRS
t = Tenant.create!(id: 2, name: 'o2_touch', subdomain: 'o2touch', i18n: 'o2_touch')
"#{t.name.upcase}_ATTRS".constantize.each do |k, v|
	t.send("#{k}=".to_sym, v)
end	
t.save
