unless Rails.env.test?
  require 'factory_girl'
  Dir[File.dirname(__FILE__) + '/../spec/factories/*'].each {|file| require file }
end

class FollowerMailPreview < MailView     
  def follower_invited__pending_app_download
    @user = FactoryGirl.build(:user)
    @user.username = "followerinvitedpendingappdownload"
    @user.save!

    @team = random(Team)
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id
    }
    
    mail = Ns2UserMailer.follower_invited(@user.id, @data)
    
    @user.destroy

    mail
  end

  def follower_invited
    @user = FactoryGirl.build(:user)
    @user.username = "followerinvited"
    @user.mobile_devices = [FactoryGirl.create(:mobile_device, :user => @user)]
    @user.save!

    @team = random(Team)
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id
    }
    
    mail = Ns2UserMailer.follower_invited(@user.id, @data)

    @user.mobile_devices.map(&:destroy)
    @user.destroy
    
    mail
  end

  def follower_invited__pending_team_invite
    @user = FactoryGirl.build(:user)
    @user.username = "followerinvitedpendingteaminvite"
    @user.save!


    @team = random(Team)
    TeamInvite.get_invite(@team, @user)
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id
    }
    
    mail = Ns2UserMailer.follower_invited(@user.id, @data)

    @user.destroy
    
    mail
  end
  
  def user_imported
    @user = User.last
    @user.username = "userimported"
    # @user.mobile_devices = [FactoryGirl.create(:mobile_device, :user => @user)]

    @team = random(Team)
    @team_invite = TeamInvite.first
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id,
      team_invite_id: @team_invite.id,
    }
    
    mail = Ns2UserMailer.user_imported(@user.id, @data)

    @user.mobile_devices.map(&:destroy)
    @user.destroy
    
    mail
  end

  def follower_registered
    @user = FactoryGirl.build(:user)
    @user.username = "followerregistered"
    @user.mobile_devices = [FactoryGirl.create(:mobile_device, :user => @user)]
    @user.save!

    @team = random(Team)
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id
    }
    
    mail = Ns2UserMailer.follower_registered(@user.id, @data)

    @user.mobile_devices.map(&:destroy)
    @user.destroy
    
    mail
  end

  def follower_registered__pending_app_download
    @user = FactoryGirl.build(:user)
    @user.username = "followerregisteredpendingappdownload"
    @user.save!

    @team = random(Team)
    @league = random(League)
    @data = {
      team_id: @team.id,
      league_id: @league.id
    }
    
    mail = Ns2UserMailer.follower_registered(@user.id, @data)

    @user.mobile_devices.map(&:destroy)
    @user.destroy
    
    mail
  end

  def registration_confirmation
    @user = random(User)
    mail = UserMailer.user_registered_confirmation(@user)
  end

private

  def random(model)
    model.offset(rand(model.count)).first
  end
end