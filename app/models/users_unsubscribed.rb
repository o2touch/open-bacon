class UsersUnsubscribed < ActiveRecord::Base
  attr_accessible :user_id, :email
  self.table_name = 'users_unsubscribed'
end