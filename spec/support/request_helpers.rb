module RequestHelpers
  include Devise::TestHelpers
  include Warden::Test::Helpers
  # Warden.test_mode!

  def login(user)
    #Depricated
    login_as user, scope: :user
    user
  end

  def as_user(user=nil, &block)
  	current_user = user || FactoryGirl.create(:user)
  	if request.present?
    	sign_in(current_user)
  	else
    	login_as(current_user, :scope => :user)
  	end
  	block.call if block.present?
  	return self
  end
end
