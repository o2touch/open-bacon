require 'test_helper'
require 'rails/performance_test_help'
 
class TeamPerformanceTest < ActionDispatch::PerformanceTest
  self.profile_options = { :runs => 2,
                           :metrics => [:process_time, :objects, :wall_time, :memory] }

  def setup
    seed_data
    @user = FactoryGirl.create(:user)
    @team = FactoryGirl.create(:team, :created_by => @user)
  end
 
  def test_show
  	caching do 
    	get team_path @team.id
    end
  end
end
